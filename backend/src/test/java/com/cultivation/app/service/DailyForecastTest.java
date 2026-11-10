package com.cultivation.app.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.cultivation.app.dto.DailyForecastResponse.Day;

class DailyForecastTest {

    private static final LocalDate DAY1 = LocalDate.of(2026, 5, 10);

    @Test
    void groupsSlotsIntoLocalDays() {
        List<ForecastSlot> slots = new ArrayList<>();
        for (int i = 0; i < 40; i++) {
            slots.add(slot(DAY1.atStartOfDay().plusHours(3L * i), 28, 0.1, 0, 2));
        }

        List<Day> days = WeatherService.summariseDays(slots);

        assertThat(days).hasSize(5);
        assertThat(days).extracting(Day::date)
            .containsExactly(DAY1, DAY1.plusDays(1), DAY1.plusDays(2), DAY1.plusDays(3), DAY1.plusDays(4));
    }

    @Test
    void aDayIsItsColdestHottestWettestAndWindiest() {
        List<ForecastSlot> slots = List.of(
            slot(DAY1.atTime(3, 0), 24, 0.2, 0, 1.5),
            slot(DAY1.atTime(12, 0), 33, 0.7, 4.2, 6.1),
            slot(DAY1.atTime(15, 0), 31, 0.9, 6.3, 3.0));

        Day day = WeatherService.summariseDays(slots).get(0);

        assertThat(day.minTempC()).isEqualTo(24.0);
        assertThat(day.maxTempC()).isEqualTo(34.0);
        assertThat(day.rainMm()).isEqualTo(10.5);
        assertThat(day.rainChancePercent()).isEqualTo(90);
        assertThat(day.maxWindSpeed()).isEqualTo(6.1);
    }

    @Test
    void describesTheDayByItsMidday() {
        List<ForecastSlot> slots = List.of(
            new ForecastSlot(DAY1.atTime(3, 0), 24, 25, 0, 0, 1, "clear sky", "01n"),
            new ForecastSlot(DAY1.atTime(12, 0), 31, 32, 0.8, 5, 2, "moderate rain", "10d"),
            new ForecastSlot(DAY1.atTime(21, 0), 26, 27, 0, 0, 1, "few clouds", "02n"));

        Day day = WeatherService.summariseDays(slots).get(0);

        assertThat(day.description()).isEqualTo("moderate rain");
        assertThat(day.iconUrl()).endsWith("10d@2x.png");
    }

    private static ForecastSlot slot(LocalDateTime start, double temp, double chance, double mm, double wind) {
        return new ForecastSlot(start, temp, temp + 1, chance, mm, wind, "desc", "01d");
    }
}
