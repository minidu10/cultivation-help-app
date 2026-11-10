package com.cultivation.app.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.cultivation.app.service.WeatherRiskRules.AlertType;
import com.cultivation.app.service.WeatherRiskRules.Severity;

/**
 * A planned task that the forecast puts at risk.
 *
 * The figures travel with the alert, not just the sentence: the mobile app
 * writes its own wording from {@code type} and the numbers, so the alert reads
 * in the farmer's language. {@code message} is the English version used by
 * the web app and the daily email.
 *
 * @param reminderId  null for alerts about a field rather than a task (heat)
 * @param suggestedAt a better time for the same task, when the forecast shows one
 */
public record WeatherAlertResponse(
        AlertType type,
        Severity severity,
        Long cropId,
        String cropName,
        Long reminderId,
        String reminderTitle,
        LocalDateTime reminderAt,
        String location,
        LocalDate date,
        int rainChancePercent,
        double rainMm,
        double windSpeed,
        double maxTempC,
        LocalDateTime suggestedAt,
        String message) {
}
