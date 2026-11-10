package com.cultivation.app.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.server.ResponseStatusException;

import com.cultivation.app.dto.WeatherAlertResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.Reminder;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.ReminderRepository;
import com.cultivation.app.service.OpenWeatherClient.GeocodedPoint;
import com.cultivation.app.service.WeatherRiskRules.Risk;

/**
 * Checks a farmer's upcoming tasks against the forecast for each field.
 *
 * Best effort by design: weather is advice, not data the farmer entered, so
 * any failure (no API key, OpenWeather down, an unknown place name) means
 * fewer alerts, never an error on the page that asked for them.
 */
@Service
public class WeatherAlertService {

    private static final Logger log = LoggerFactory.getLogger(WeatherAlertService.class);

    /** The free forecast's horizon; nothing beyond it can be judged. */
    static final int HORIZON_DAYS = 5;

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("EEE d MMM", Locale.ENGLISH);
    private static final DateTimeFormatter TIME = DateTimeFormatter.ofPattern("h:mm a", Locale.ENGLISH);

    private final WeatherService weatherService;
    private final ReminderRepository reminderRepository;
    private final CropRepository cropRepository;

    public WeatherAlertService(WeatherService weatherService,
                               ReminderRepository reminderRepository,
                               CropRepository cropRepository) {
        this.weatherService = weatherService;
        this.reminderRepository = reminderRepository;
        this.cropRepository = cropRepository;
    }

    /** Every alert for the farmer's next five days, most urgent first. */
    @Transactional(readOnly = true)
    public List<WeatherAlertResponse> alertsFor(User user) {
        LocalDateTime now = LocalDateTime.now();
        List<Reminder> reminders = reminderRepository.findActiveForUserBetween(
            user.getId(), now, now.plusDays(HORIZON_DAYS));
        List<Crop> activeCrops = cropRepository.findByUserIdOrderByCreatedAtDesc(user.getId()).stream()
            .filter(c -> c.getStatus() != Crop.CropStatus.HARVESTED && c.getStatus() != Crop.CropStatus.FAILED)
            .toList();
        return evaluate(user, reminders, activeCrops, now);
    }

    /** Task alerts keyed by reminder id, for the daily email. Heat alerts are left out. */
    public Map<Long, WeatherAlertResponse> alertsByReminder(User user, List<Reminder> reminders) {
        return evaluate(user, reminders, List.of(), LocalDateTime.now()).stream()
            .filter(a -> a.reminderId() != null)
            .collect(Collectors.toMap(WeatherAlertResponse::reminderId, a -> a, (a, b) -> a));
    }

    List<WeatherAlertResponse> evaluate(User user, List<Reminder> reminders, List<Crop> activeCrops,
                                        LocalDateTime now) {
        Forecasts forecasts = new Forecasts(user);
        List<WeatherAlertResponse> alerts = new ArrayList<>();

        for (Reminder reminder : reminders) {
            Crop crop = reminder.getCrop();
            forecasts.forCrop(crop).ifPresent(field ->
                WeatherRiskRules.assess(reminder.getType(), reminder.getReminderAt(), field.slots(), now)
                    .ifPresent(risk -> alerts.add(toResponse(risk, crop.getId(), crop.getName(), reminder,
                                                              field.place()))));
        }

        // Heat is about the field, not a task: one alert per place, naming
        // every crop growing there, rather than one per crop.
        Map<String, List<Crop>> cropsByPlace = new LinkedHashMap<>();
        Map<String, Field> fieldByPlace = new HashMap<>();
        for (Crop crop : activeCrops) {
            forecasts.forCrop(crop).ifPresent(field -> {
                cropsByPlace.computeIfAbsent(field.place(), p -> new ArrayList<>()).add(crop);
                fieldByPlace.put(field.place(), field);
            });
        }
        cropsByPlace.forEach((place, crops) ->
            WeatherRiskRules.heat(fieldByPlace.get(place).slots(), now).ifPresent(risk -> alerts.add(toResponse(
                risk,
                crops.size() == 1 ? crops.get(0).getId() : null,
                crops.stream().map(Crop::getName).distinct().collect(Collectors.joining(", ")),
                null,
                place))));

        alerts.sort(Comparator
            .comparing(WeatherAlertResponse::severity)
            .thenComparing(WeatherAlertResponse::date)
            .thenComparing(a -> a.reminderAt() == null ? LocalDateTime.MAX : a.reminderAt()));
        return alerts;
    }

    // ------------------------------------------------------------- messages

    private static WeatherAlertResponse toResponse(Risk risk, Long cropId, String cropName,
                                                   Reminder reminder, String place) {
        return new WeatherAlertResponse(
            risk.type(), risk.severity(), cropId, cropName,
            reminder == null ? null : reminder.getId(),
            reminder == null ? null : reminder.getTitle(),
            reminder == null ? null : reminder.getReminderAt(),
            place, risk.date(), risk.rainChancePercent(), risk.rainMm(), risk.windSpeed(), risk.maxTempC(),
            risk.suggestedAt(),
            message(risk, cropName, reminder, place));
    }

    /** One plain sentence, then what to do about it. */
    static String message(Risk risk, String cropName, Reminder reminder, String place) {
        String task = reminder == null ? "" : "\"" + reminder.getTitle() + "\"";
        String day = risk.date().format(DAY);
        String rain = rainFigures(risk);
        String move = risk.suggestedAt() == null ? ""
            : " A better time: " + risk.suggestedAt().format(DAY) + ", " + risk.suggestedAt().format(TIME) + ".";
        return switch (risk.type()) {
            case RAIN_WASHOFF -> "Rain likely on " + day + rain + ". " + task + " for " + cropName
                + " may wash off before it soaks in." + (move.isEmpty() ? " Wait for a dry spell." : move);
            case SPRAY_WIND -> "Wind up to " + risk.windSpeed() + " m/s on " + day + ". Spray for " + cropName
                + " will drift off target." + (move.isEmpty() ? " Spray early morning when it is calm." : move);
            case IRRIGATION_RAIN -> "Rain expected on " + day + rain + ". You can probably skip " + task
                + " for " + cropName + " and save the water.";
            case HARVEST_RAIN -> "Rain likely on " + day + rain + ". Harvesting " + cropName
                + " wet risks spoilage in storage." + (move.isEmpty() ? " Keep tarpaulins ready." : move);
            case HEAT_STRESS -> "Up to " + Math.round(risk.maxTempC()) + "°C at " + place + " on " + day
                + ". Water " + cropName + " early morning or evening, and mulch to hold moisture.";
        };
    }

    private static String rainFigures(Risk risk) {
        return risk.rainMm() >= 1
            ? " (" + risk.rainChancePercent() + "% chance, about " + Math.round(risk.rainMm()) + " mm)"
            : " (" + risk.rainChancePercent() + "% chance)";
    }

    // ------------------------------------------------------------ forecasts

    private record Field(String place, List<ForecastSlot> slots) {
    }

    /**
     * Looks up each place once per request. A crop's own field location wins;
     * one with none, or one that cannot be found ("North Field"), uses the
     * farmer's town. A farmer with neither gets no weather alerts.
     */
    private final class Forecasts {
        private final User user;
        private final Map<String, Optional<Field>> byQuery = new HashMap<>();

        Forecasts(User user) {
            this.user = user;
        }

        Optional<Field> forCrop(Crop crop) {
            return lookup(crop.getFieldLocation()).or(() -> lookup(user.getCity()));
        }

        private Optional<Field> lookup(String query) {
            if (query == null || query.isBlank()) {
                return Optional.empty();
            }
            return byQuery.computeIfAbsent(query.trim().toLowerCase(Locale.ROOT), key -> {
                try {
                    return weatherService.resolve(query)
                        .map(point -> new Field(placeName(point, query), weatherService.slotsFor(point)))
                        .filter(field -> !field.slots().isEmpty());
                } catch (ResponseStatusException | RestClientException ex) {
                    log.debug("No forecast for '{}': {}", query, ex.getMessage());
                    return Optional.empty();
                }
            });
        }

        private static String placeName(GeocodedPoint point, String query) {
            return point.displayName() == null || point.displayName().isBlank() ? query.trim() : point.displayName();
        }
    }
}
