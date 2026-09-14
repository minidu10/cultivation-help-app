package com.cultivation.app.service;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.dto.CropInsightResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.CropInsight;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.CropInsightRepository;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.ExpenseRepository;
import com.cultivation.app.repository.HarvestRepository;

/**
 * Serves the AI insight for a crop, generating one only when it would differ.
 *
 * The dashboard asks for an insight per crop on every load. Regenerating each
 * time costs tokens to produce text identical to what was shown a moment
 * earlier, so the result is stored against a fingerprint of the figures it was
 * derived from. Add an expense and the fingerprint moves, so exactly that one
 * crop is regenerated; open the dashboard fifty more times and nothing is sent
 * to the model at all.
 */
@Service
public class CropInsightService {

    private static final Logger log = LoggerFactory.getLogger(CropInsightService.class);

    private final CropRepository cropRepository;
    private final ExpenseRepository expenseRepository;
    private final HarvestRepository harvestRepository;
    private final CropInsightRepository insightRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    private final String aiServiceUrl;

    public CropInsightService(CropRepository cropRepository,
                              ExpenseRepository expenseRepository,
                              HarvestRepository harvestRepository,
                              CropInsightRepository insightRepository,
                              @Value("${app.ai.service-url:http://ai-service:8000}") String aiServiceUrl) {
        this.cropRepository = cropRepository;
        this.expenseRepository = expenseRepository;
        this.harvestRepository = harvestRepository;
        this.insightRepository = insightRepository;
        this.aiServiceUrl = aiServiceUrl;
    }

    @Transactional
    public CropInsightResponse getInsight(Long cropId, User currentUser, boolean forceRefresh) {
        Crop crop = cropRepository.findByIdAndUserId(cropId, currentUser.getId())
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));

        if (Boolean.FALSE.equals(crop.getAiInsightsEnabled())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "AI insights are turned off for this crop");
        }

        BigDecimal expenses = expenseRepository.sumAmountByCropId(cropId);
        BigDecimal revenue = harvestRepository.sumRevenueByCropId(cropId);
        String fingerprint = fingerprint(crop, expenses, revenue);

        Optional<CropInsight> cached = insightRepository.findById(cropId);
        if (!forceRefresh
            && cached.isPresent()
            && fingerprint.equals(cached.get().getFingerprint())) {
            CropInsight hit = cached.get();
            return new CropInsightResponse(cropId, crop.getName(), hit.getContent(),
                                           hit.getGeneratedAt(), false);
        }

        String text = generate(crop, expenses, revenue);

        CropInsight record = cached.orElseGet(() -> new CropInsight(cropId, fingerprint, text));
        record.refresh(fingerprint, text);
        CropInsight saved = insightRepository.save(record);

        log.info("Generated insight for crop {} ({})", cropId, crop.getName());
        return new CropInsightResponse(cropId, crop.getName(), saved.getContent(),
                                       saved.getGeneratedAt(), true);
    }

    /**
     * Everything the insight text depends on. Anything the model was told goes
     * in here, or the cache would keep serving advice based on stale figures.
     */
    private static String fingerprint(Crop crop, BigDecimal expenses, BigDecimal revenue) {
        String material = String.join("|",
            crop.getName(),
            String.valueOf(crop.getStatus()),
            expenses.stripTrailingZeros().toPlainString(),
            revenue.stripTrailingZeros().toPlainString());
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                .digest(material.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 unavailable", ex);
        }
    }

    private String generate(Crop crop, BigDecimal expenses, BigDecimal revenue) {
        Map<String, Object> body = Map.of(
            "crop_name", crop.getName(),
            "total_expenses", expenses,
            "total_revenue", revenue,
            "net_profit", revenue.subtract(expenses),
            "status", String.valueOf(crop.getStatus()));

        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.postForObject(
                aiServiceUrl + "/ai/insights", body, Map.class);

            String text = response == null ? null : (String) response.get("insights");
            if (text == null || text.isBlank()) {
                throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "AI returned no insight");
            }
            return text;
        } catch (RestClientException ex) {
            log.warn("AI insight request failed for crop {}: {}", crop.getId(), ex.getMessage());
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                "The AI service is unavailable. Try again shortly.");
        }
    }
}
