package com.cultivation.app.service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;

/**
 * One 3-hour slot of the OpenWeather forecast, in farm-local time.
 *
 * OpenWeather reports UTC; reminders are stored as local time with no zone.
 * Converting here, once, means every comparison between a reminder and the
 * weather is like for like.
 *
 * @param start      when the slot begins (local)
 * @param tempC      temperature
 * @param tempMaxC   the slot's maximum temperature
 * @param rainChance probability of precipitation, 0 to 1
 * @param rainMm     rain expected during the slot's three hours
 * @param windSpeed  metres per second
 */
public record ForecastSlot(
        LocalDateTime start,
        double tempC,
        double tempMaxC,
        double rainChance,
        double rainMm,
        double windSpeed,
        String description,
        String iconCode) {

    public static final int HOURS = 3;

    public LocalDateTime end() {
        return start.plusHours(HOURS);
    }

    /** True when the slot overlaps [from, to). */
    public boolean overlaps(LocalDateTime from, LocalDateTime to) {
        return start.isBefore(to) && end().isAfter(from);
    }

    public static List<ForecastSlot> parse(JsonNode forecast, ZoneId zone) {
        List<ForecastSlot> slots = new ArrayList<>();
        for (JsonNode item : forecast.path("list")) {
            if (!item.hasNonNull("dt")) {
                continue;
            }
            JsonNode main = item.path("main");
            JsonNode weather = item.path("weather").path(0);
            slots.add(new ForecastSlot(
                LocalDateTime.ofInstant(Instant.ofEpochSecond(item.path("dt").asLong()), zone),
                main.path("temp").asDouble(),
                main.path("temp_max").asDouble(main.path("temp").asDouble()),
                item.path("pop").asDouble(0),
                item.path("rain").path("3h").asDouble(0),
                item.path("wind").path("speed").asDouble(0),
                weather.path("description").asText(null),
                weather.path("icon").asText(null)));
        }
        return slots;
    }
}
