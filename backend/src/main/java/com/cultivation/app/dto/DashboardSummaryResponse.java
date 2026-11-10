package com.cultivation.app.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.cultivation.app.entity.Crop;

/**
 * Everything the dashboard's first paint needs, in one response.
 *
 * The web dashboard used to make a profit/loss call per crop and add the
 * results up in the browser. On a rural mobile connection each round trip
 * costs real seconds, so the server does the arithmetic once.
 */
public record DashboardSummaryResponse(
        Totals totals,
        List<CropSummary> crops,
        List<ReminderResponse> dueReminders,
        List<ReminderResponse> upcomingReminders) {

    public record Totals(
            BigDecimal totalRevenue,
            BigDecimal totalExpenses,
            BigDecimal netProfit,
            int activeCrops,
            int totalCrops) {
    }

    public record CropSummary(
            Long cropId,
            String cropName,
            String variety,
            Crop.CropStatus status,
            String fieldLocation,
            LocalDate plantingDate,
            LocalDate expectedHarvestDate,
            Boolean aiInsightsEnabled,
            BigDecimal totalExpenses,
            BigDecimal totalRevenue,
            BigDecimal netProfit,
            String result) {
    }
}
