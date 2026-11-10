package com.cultivation.app.dto;

import java.time.LocalDate;
import java.util.List;

/** The free OpenWeather tier's five days of 3-hour slots, summarised per day. */
public record DailyForecastResponse(String location, List<Day> days) {

    public record Day(
            LocalDate date,
            double minTempC,
            double maxTempC,
            double rainMm,
            int rainChancePercent,
            double maxWindSpeed,
            String description,
            String iconUrl) {
    }
}
