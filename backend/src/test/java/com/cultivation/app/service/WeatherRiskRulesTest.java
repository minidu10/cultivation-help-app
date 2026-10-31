package com.cultivation.app.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import com.cultivation.app.entity.Reminder.ReminderType;
import com.cultivation.app.service.WeatherRiskRules.AlertType;
import com.cultivation.app.service.WeatherRiskRules.Risk;
import com.cultivation.app.service.WeatherRiskRules.Severity;

class WeatherRiskRulesTest {

    /** Day 1 of a five-day forecast; the farmer is looking at it at 6 AM. */
    private static final LocalDate DAY1 = LocalDate.of(2026, 5, 10);
    private static final LocalDateTime NOW = DAY1.atTime(6, 0);

    /** Forty 3-hour slots of fine weather from midnight on day 1. */
    private final List<ForecastSlot> slots = fine();

    private static List<ForecastSlot> fine() {
        List<ForecastSlot> list = new ArrayList<>();
        for (int i = 0; i < 40; i++) {
            list.add(new ForecastSlot(DAY1.atStartOfDay().plusHours(3L * i), 30, 31, 0.1, 0, 2, "clear sky", "01d"));
        }
        return list;
    }

    /** Overwrites the slot starting at {@code start}. */
    private void set(LocalDateTime start, double chance, double mm, double wind, double maxTemp) {
        for (int i = 0; i < slots.size(); i++) {
            if (slots.get(i).start().equals(start)) {
                slots.set(i, new ForecastSlot(start, maxTemp - 1, maxTemp, chance, mm, wind, "x", "10d"));
                return;
            }
        }
        throw new IllegalArgumentException("No slot at " + start);
    }

    private void rain(LocalDateTime start, double chance, double mm) {
        set(start, chance, mm, 2, 31);
    }

    /** Rain at midday every day from {@code from} to the end of the forecast. */
    private void rainEveryDayFrom(LocalDate from) {
        for (LocalDate d = from; !d.isAfter(DAY1.plusDays(4)); d = d.plusDays(1)) {
            rain(d.atTime(12, 0), 0.9, 12);
        }
    }

    private Optional<Risk> assess(ReminderType type, LocalDateTime at) {
        return WeatherRiskRules.assess(type, at, slots, NOW);
    }

    private static LocalDateTime day(int n, int hour) {
        return DAY1.plusDays(n - 1L).atTime(hour, 0);
    }

    @Nested
    class Fertilizer {

        @Test
        void fineWeatherIsNoRisk() {
            assertThat(assess(ReminderType.FERTILIZER, day(1, 9))).isEmpty();
        }

        @Test
        void likelyRainThatAfternoonWashesItOff() {
            rain(day(1, 15), 0.85, 8);

            Risk risk = assess(ReminderType.FERTILIZER, day(1, 9)).orElseThrow();

            assertThat(risk.type()).isEqualTo(AlertType.RAIN_WASHOFF);
            assertThat(risk.severity()).isEqualTo(Severity.HIGH);
            assertThat(risk.date()).isEqualTo(DAY1);
            assertThat(risk.rainChancePercent()).isEqualTo(85);
            assertThat(risk.rainMm()).isEqualTo(8.0);
        }

        @Test
        void suggestsTheSameTimeOnTheNextDryDay() {
            rain(day(1, 15), 0.85, 8);

            assertThat(assess(ReminderType.FERTILIZER, day(1, 9)).orElseThrow().suggestedAt()).isEqualTo(day(2, 9));
        }

        @Test
        void skipsDaysThatAreWetToo() {
            rain(day(1, 15), 0.85, 8);
            rain(day(2, 15), 0.85, 8);

            assertThat(assess(ReminderType.FERTILIZER, day(1, 9)).orElseThrow().suggestedAt()).isEqualTo(day(3, 9));
        }

        @Test
        void suggestsNothingWhenEveryRemainingDayIsWet() {
            rainEveryDayFrom(DAY1);

            assertThat(assess(ReminderType.FERTILIZER, day(1, 9)).orElseThrow().suggestedAt()).isNull();
        }

        /**
         * Day 5 is dry, but a 9 AM application there needs forecast up to 9 AM
         * on day 6, which does not exist. Better silence than a guess.
         */
        @Test
        void neverSuggestsATimeTheForecastCannotVouchFor() {
            rainEveryDayFrom(DAY1);
            slots.replaceAll(s -> s.start().toLocalDate().equals(DAY1.plusDays(4))
                ? new ForecastSlot(s.start(), 30, 31, 0.1, 0, 2, "clear", "01d") : s);

            assertThat(assess(ReminderType.FERTILIZER, day(4, 9)).orElseThrow().suggestedAt()).isNull();
        }

        @Test
        void heavyRainCountsEvenAtModestProbability() {
            rain(day(1, 15), 0.40, 3);
            rain(day(1, 18), 0.40, 3);

            Risk risk = assess(ReminderType.FERTILIZER, day(1, 9)).orElseThrow();

            assertThat(risk.rainMm()).isEqualTo(6.0);
            assertThat(risk.severity()).isEqualTo(Severity.MEDIUM);
        }

        @Test
        void aPassingShowerBelowBothThresholdsIsFine() {
            rain(day(1, 15), 0.50, 2);

            assertThat(assess(ReminderType.FERTILIZER, day(1, 9))).isEmpty();
        }

        @Test
        void rainMoreThanADayAfterApplicationDoesNotMatter() {
            rain(day(2, 15), 0.95, 20);

            assertThat(assess(ReminderType.FERTILIZER, day(1, 9))).isEmpty();
        }
    }

    @Nested
    class Spraying {

        @Test
        void windAtSprayTimeCausesDrift() {
            set(day(2, 9), 0.1, 0, 6.5, 31);

            Risk risk = assess(ReminderType.PEST_CONTROL, day(2, 10)).orElseThrow();

            assertThat(risk.type()).isEqualTo(AlertType.SPRAY_WIND);
            assertThat(risk.severity()).isEqualTo(Severity.MEDIUM);
            assertThat(risk.windSpeed()).isEqualTo(6.5);
            assertThat(risk.suggestedAt()).isEqualTo(day(3, 10));
        }

        @Test
        void galeIsHighSeverity() {
            set(day(2, 9), 0.1, 0, 9, 31);

            assertThat(assess(ReminderType.PEST_CONTROL, day(2, 10)).orElseThrow().severity()).isEqualTo(Severity.HIGH);
        }

        @Test
        void exactlyTheLimitIsStillCalmEnough() {
            set(day(2, 9), 0.1, 0, 5.0, 31);

            assertThat(assess(ReminderType.PEST_CONTROL, day(2, 10))).isEmpty();
        }

        @Test
        void rainOutranksWindWhenBothThreaten() {
            set(day(2, 9), 0.9, 10, 7, 31);

            assertThat(assess(ReminderType.PEST_CONTROL, day(2, 10)).orElseThrow().type())
                .isEqualTo(AlertType.RAIN_WASHOFF);
        }

        @Test
        void fertilizerDoesNotCareAboutWind() {
            set(day(2, 9), 0.1, 0, 9, 31);

            assertThat(assess(ReminderType.FERTILIZER, day(2, 10))).isEmpty();
        }
    }

    @Nested
    class Irrigation {

        @Test
        void likelyRainMeansTheWateringCanWait() {
            rain(day(2, 12), 0.75, 6);

            Risk risk = assess(ReminderType.IRRIGATION, day(2, 7)).orElseThrow();

            assertThat(risk.type()).isEqualTo(AlertType.IRRIGATION_RAIN);
            assertThat(risk.suggestedAt()).isNull();
        }

        @Test
        void aMaybeShowerIsNotEnoughToSkip() {
            rain(day(2, 12), 0.60, 2);

            assertThat(assess(ReminderType.IRRIGATION, day(2, 7))).isEmpty();
        }
    }

    @Nested
    class Harvest {

        @Test
        void daytimeRainOnHarvestDayIsARisk() {
            rain(day(3, 12), 0.7, 4);

            Risk risk = assess(ReminderType.HARVEST, day(3, 8)).orElseThrow();

            assertThat(risk.type()).isEqualTo(AlertType.HARVEST_RAIN);
            assertThat(risk.date()).isEqualTo(DAY1.plusDays(2));
        }

        @Test
        void prefersBringingTheHarvestForward() {
            rain(day(3, 12), 0.7, 4);

            assertThat(assess(ReminderType.HARVEST, day(3, 8)).orElseThrow().suggestedAt()).isEqualTo(day(2, 8));
        }

        @Test
        void putsItBackWhenEarlierIsAlsoWet() {
            rain(day(2, 12), 0.7, 4);
            rain(day(3, 12), 0.7, 4);

            assertThat(assess(ReminderType.HARVEST, day(3, 8)).orElseThrow().suggestedAt()).isEqualTo(day(4, 8));
        }

        @Test
        void neverSuggestsAnEarlierTimeThatHasPassed() {
            rain(day(2, 12), 0.7, 4);

            // Day 1 at 8 AM is two hours after "now": fine. Day 1 at 5 AM is not.
            assertThat(assess(ReminderType.HARVEST, day(2, 8)).orElseThrow().suggestedAt()).isEqualTo(day(1, 8));
            assertThat(assess(ReminderType.HARVEST, day(2, 5)).orElseThrow().suggestedAt()).isEqualTo(day(3, 5));
        }

        @Test
        void rainOvernightDoesNotStopADayHarvest() {
            rain(day(3, 21), 0.9, 15);

            assertThat(assess(ReminderType.HARVEST, day(3, 8))).isEmpty();
        }
    }

    @Nested
    class Heat {

        @Test
        void aHotDayInTheNextThreeIsReported() {
            set(day(2, 12), 0.1, 0, 2, 36.4);
            set(day(2, 15), 0.1, 0, 2, 37.0);

            Risk risk = WeatherRiskRules.heat(slots, NOW).orElseThrow();

            assertThat(risk.type()).isEqualTo(AlertType.HEAT_STRESS);
            assertThat(risk.date()).isEqualTo(DAY1.plusDays(1));
            assertThat(risk.maxTempC()).isEqualTo(37.0);
            assertThat(risk.severity()).isEqualTo(Severity.MEDIUM);
        }

        @Test
        void extremeHeatIsHighSeverity() {
            set(day(1, 12), 0.1, 0, 2, 39);

            assertThat(WeatherRiskRules.heat(slots, NOW).orElseThrow().severity()).isEqualTo(Severity.HIGH);
        }

        @Test
        void justBelowTheLineIsFine() {
            set(day(2, 12), 0.1, 0, 2, 34.9);

            assertThat(WeatherRiskRules.heat(slots, NOW)).isEmpty();
        }

        @Test
        void heatFurtherOutThanThreeDaysIsLeftForLater() {
            set(day(4, 12), 0.1, 0, 2, 38);

            assertThat(WeatherRiskRules.heat(slots, NOW)).isEmpty();
        }
    }

    @Nested
    class Scope {

        @Test
        void generalRemindersAreNeverWeatherSensitive() {
            rainEveryDayFrom(DAY1);

            assertThat(assess(ReminderType.OTHER, day(1, 9))).isEmpty();
        }

        @Test
        void tasksAlreadyPastAreIgnored() {
            rain(day(1, 3), 0.9, 10);

            assertThat(assess(ReminderType.FERTILIZER, day(1, 2))).isEmpty();
        }

        @Test
        void tasksBeyondTheForecastAreNotGuessedAt() {
            assertThat(assess(ReminderType.FERTILIZER, day(9, 9))).isEmpty();
        }

        @Test
        void noForecastMeansNoAlert() {
            assertThat(WeatherRiskRules.assess(ReminderType.FERTILIZER, day(1, 9), List.of(), NOW)).isEmpty();
        }
    }
}
