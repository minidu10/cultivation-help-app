package com.cultivation.app.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.dto.DiagnosisResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.CropDiagnosis;
import com.cultivation.app.entity.CropDiagnosisThumbnail;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.CropDiagnosisRepository;
import com.cultivation.app.repository.CropDiagnosisThumbnailRepository;
import com.cultivation.app.repository.CropRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * The crop doctor: a photo in, a likely diagnosis out, kept in the crop's history.
 *
 * Each photo costs a vision-model call, so two limits apply: the AI allowance
 * every AI feature shares, and a daily count of photos. The count is read from
 * the database rather than kept in memory, so a restart does not reset it.
 */
@Service
public class DiagnosisService {

    private static final Logger log = LoggerFactory.getLogger(DiagnosisService.class);
    private static final ObjectMapper JSON = new ObjectMapper();
    private static final TypeReference<Map<String, List<String>>> DETAILS = new TypeReference<>() {};
    private static final int MAX_NOTE = 300;

    private final CropRepository cropRepository;
    private final CropDiagnosisRepository diagnosisRepository;
    private final CropDiagnosisThumbnailRepository thumbnailRepository;
    private final PhotoProcessor photoProcessor;
    private final AiAdvisorService aiAdvisorService;
    private final RestTemplate restTemplate;
    private final TransactionTemplate transaction;
    private final String aiServiceUrl;
    private final int dailyLimit;

    public DiagnosisService(CropRepository cropRepository,
                            CropDiagnosisRepository diagnosisRepository,
                            CropDiagnosisThumbnailRepository thumbnailRepository,
                            PhotoProcessor photoProcessor,
                            AiAdvisorService aiAdvisorService,
                            @Qualifier("aiRestTemplate") RestTemplate restTemplate,
                            TransactionTemplate transaction,
                            @Value("${app.ai.service-url:http://ai-service:8000}") String aiServiceUrl,
                            @Value("${app.diagnosis.daily-limit:10}") int dailyLimit) {
        this.cropRepository = cropRepository;
        this.diagnosisRepository = diagnosisRepository;
        this.thumbnailRepository = thumbnailRepository;
        this.photoProcessor = photoProcessor;
        this.aiAdvisorService = aiAdvisorService;
        this.restTemplate = restTemplate;
        this.transaction = transaction;
        this.aiServiceUrl = aiServiceUrl;
        this.dailyLimit = dailyLimit;
    }

    public DiagnosisResponse diagnose(Long cropId, byte[] upload, String note, User user) {
        Crop crop = findCrop(cropId, user);
        String cleanNote = note == null || note.isBlank() ? null : note.trim();
        if (cleanNote != null && cleanNote.length() > MAX_NOTE) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Note must be at most " + MAX_NOTE + " characters");
        }

        long today = diagnosisRepository.countByCropUserIdAndCreatedAtGreaterThanEqual(
            user.getId(), LocalDate.now().atStartOfDay());
        if (today >= dailyLimit) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                "You have checked " + dailyLimit + " photos today, the daily limit. It resets tomorrow.");
        }

        // The photo is validated before any AI allowance is spent on it.
        PhotoProcessor.Prepared photo = photoProcessor.prepare(upload);
        aiAdvisorService.checkQuota(user);
        AiDiagnosis ai = callAi(photo.forAi(), hint(crop), user);

        if (!ai.isPlant()) {
            // Answered, so the app can ask for a better photo, but not kept:
            // a blurry thumb is not part of the crop's health record.
            return response(null, crop.getId(), ai, cleanNote, LocalDateTime.now());
        }

        CropDiagnosis saved = transaction.execute(status -> {
            CropDiagnosis d = new CropDiagnosis();
            d.setCrop(crop);
            d.setPlant(true);
            d.setCropGuess(truncate(ai.cropGuess(), 100));
            d.setCondition(truncate(ai.condition(), 100));
            d.setConfidence(ai.confidence());
            d.setSeverity(ai.severity());
            d.setSeeExpert(ai.seeExpert());
            d.setDetails(writeDetails(ai));
            d.setNote(cleanNote);
            d.setModel(truncate(ai.model(), 100));
            CropDiagnosis row = diagnosisRepository.save(d);
            thumbnailRepository.save(new CropDiagnosisThumbnail(row.getId(), photo.thumbnail()));
            return row;
        });
        log.info("Diagnosed crop {} for user {}: {} ({})", crop.getId(), user.getId(), ai.condition(), ai.confidence());
        return toResponse(saved);
    }

    public List<DiagnosisResponse> history(Long cropId, User user) {
        findCrop(cropId, user);
        return diagnosisRepository.findByCropIdAndCropUserIdOrderByCreatedAtDesc(cropId, user.getId()).stream()
            .map(this::toResponse)
            .toList();
    }

    public DiagnosisResponse get(Long cropId, Long diagnosisId, User user) {
        return toResponse(find(cropId, diagnosisId, user));
    }

    public byte[] thumbnail(Long cropId, Long diagnosisId, User user) {
        CropDiagnosis diagnosis = find(cropId, diagnosisId, user);
        return thumbnailRepository.findById(diagnosis.getId())
            .map(CropDiagnosisThumbnail::getImage)
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Photo not found"));
    }

    public void delete(Long cropId, Long diagnosisId, User user) {
        CropDiagnosis diagnosis = find(cropId, diagnosisId, user);
        transaction.executeWithoutResult(status -> {
            thumbnailRepository.deleteById(diagnosis.getId());
            diagnosisRepository.delete(diagnosis);
        });
    }

    // -------------------------------------------------------------- AI call

    /** The model's answer, already validated and normalised by the AI service. */
    record AiDiagnosis(boolean isPlant, String cropGuess, String condition, double confidence, String severity,
                       boolean seeExpert, List<String> symptoms, List<String> treatmentOrganic,
                       List<String> treatmentChemical, List<String> prevention, String model) {
    }

    private AiDiagnosis callAi(byte[] jpeg, String hint, User user) {
        Map<String, Object> body = Map.of(
            "image_base64", Base64.getEncoder().encodeToString(jpeg),
            "mime_type", "image/jpeg",
            "crop_hint", hint);
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> r = restTemplate.postForObject(aiServiceUrl + "/ai/diagnose", body, Map.class);
            if (r == null) {
                throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "The crop doctor returned no answer");
            }
            return new AiDiagnosis(
                Boolean.TRUE.equals(r.get("isPlant")),
                text(r.get("cropGuess")),
                text(r.get("condition")),
                r.get("confidence") instanceof Number n ? Math.max(0, Math.min(1, n.doubleValue())) : 0,
                text(r.get("severity")),
                Boolean.TRUE.equals(r.get("seeExpert")),
                list(r.get("symptoms")),
                list(r.get("treatmentOrganic")),
                list(r.get("treatmentChemical")),
                list(r.get("prevention")),
                text(r.get("model")));
        } catch (HttpClientErrorException ex) {
            log.warn("AI rejected a diagnosis request for user {}: {}", user.getId(), ex.getMessage());
            throw new ApiException(HttpStatus.BAD_REQUEST, "That photo could not be analysed. Try another one.");
        } catch (RestClientException ex) {
            log.warn("Crop doctor unavailable for user {}: {}", user.getId(), ex.getMessage());
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                "The crop doctor is unavailable right now. Try again shortly.");
        }
    }

    /** Telling the model what the farmer planted makes its guess far better. */
    private static String hint(Crop crop) {
        return crop.getVariety() == null || crop.getVariety().isBlank()
            ? crop.getName()
            : crop.getName() + " (" + crop.getVariety() + ")";
    }

    // ------------------------------------------------------------- mapping

    private DiagnosisResponse toResponse(CropDiagnosis d) {
        Map<String, List<String>> details = readDetails(d.getDetails());
        AiDiagnosis view = new AiDiagnosis(
            Boolean.TRUE.equals(d.getPlant()), d.getCropGuess(), d.getCondition(), d.getConfidence(),
            d.getSeverity(), Boolean.TRUE.equals(d.getSeeExpert()),
            details.getOrDefault("symptoms", List.of()),
            details.getOrDefault("treatmentOrganic", List.of()),
            details.getOrDefault("treatmentChemical", List.of()),
            details.getOrDefault("prevention", List.of()),
            d.getModel());
        return response(d.getId(), d.getCrop().getId(), view, d.getNote(), d.getCreatedAt());
    }

    private static DiagnosisResponse response(Long id, Long cropId, AiDiagnosis ai, String note,
                                              LocalDateTime createdAt) {
        return new DiagnosisResponse(id, cropId, ai.isPlant(), ai.cropGuess(), ai.condition(), ai.confidence(),
            ai.severity(), ai.seeExpert(), ai.symptoms(), ai.treatmentOrganic(), ai.treatmentChemical(),
            ai.prevention(), note, createdAt,
            id == null ? null : "/api/crops/" + cropId + "/diagnoses/" + id + "/thumbnail");
    }

    private static String writeDetails(AiDiagnosis ai) {
        Map<String, List<String>> details = new LinkedHashMap<>();
        details.put("symptoms", ai.symptoms());
        details.put("treatmentOrganic", ai.treatmentOrganic());
        details.put("treatmentChemical", ai.treatmentChemical());
        details.put("prevention", ai.prevention());
        try {
            return JSON.writeValueAsString(details);
        } catch (JsonProcessingException ex) {
            throw new IllegalStateException("Could not store diagnosis details", ex);
        }
    }

    private static Map<String, List<String>> readDetails(String json) {
        try {
            return json == null ? Map.of() : JSON.readValue(json, DETAILS);
        } catch (JsonProcessingException ex) {
            log.warn("Unreadable diagnosis details: {}", ex.getMessage());
            return Map.of();
        }
    }

    private static String text(Object value) {
        return value == null ? "" : value.toString().trim();
    }

    private static List<String> list(Object value) {
        return value instanceof List<?> items
            ? items.stream().filter(i -> i != null && !i.toString().isBlank()).map(i -> i.toString().trim()).toList()
            : List.of();
    }

    private static String truncate(String value, int max) {
        return value == null || value.length() <= max ? value : value.substring(0, max);
    }

    // -------------------------------------------------------------- lookups

    private Crop findCrop(Long cropId, User user) {
        return cropRepository.findByIdAndUserId(cropId, user.getId())
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));
    }

    private CropDiagnosis find(Long cropId, Long diagnosisId, User user) {
        return diagnosisRepository.findByIdAndCropIdAndCropUserId(diagnosisId, cropId, user.getId())
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Diagnosis not found"));
    }
}
