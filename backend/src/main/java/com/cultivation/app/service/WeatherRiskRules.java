package com.cultivation.app.service;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;

import com.cultivation.app.entity.Reminder.ReminderType;

/**
 * Decides whether the forecast puts a planned field task at risk, and when it
 * would be better done.
 *
 * Pure functions over forecast slots, with no I/O, so every threshold below is
 * pinned by a unit test. The thresholds are deliberately simple rules of thumb
 * a farmer would recognise, not a model: they need to be explainable in one
 * sentence on a phone screen.
 */
public final class WeatherRiskRules {

    public enum AlertType { RAIN_WASHOFF, SPRAY_WIND, IRRIGATION_RAIN, HARVEST_RAIN, HEAT_STRESS }

    public enum Severity { HIGH, MEDIUM }

    /**
     * A risk found for one task.
     *
     * @param date        the day the bad weather falls on
     * @param suggestedAt the nearest time the same rule would pass, if the
     *                    forecast reaches far enough to say; null otherwise
     */
    public record Risk(
            AlertType type,
            Severity severity,
            LocalDate date,
            int rainChancePercent,
            double rainMm,
            double windSpeed,
            double maxTempC,
            LocalDateTime suggestedAt) {
    }

    // Fertilizer and pesticide need a dry spell to soak in or dry on the leaf.
    // Rain within a day of application washes them off and into the drains.
    static final Duration WASHOFF_BEFORE = Duration.ofHours(3);
    static final Duration WASHOFF_AFTER = Duration.ofHours(24);
    static final double WASHOFF_CHANCE = 0.60;
    static final double WASHOFF_MM = 5.0;

    // Above about 18 km/h, spray drifts onto neighbouring plots and misses the crop.
    static final Duration SPRAY_WINDOW = Duration.ofHours(2);
    static final double SPRAY_MAX_WIND = 5.0;

    // A good shower does the irrigating; pumping water ahead of it wastes fuel.
    static final Duration IRRIGATION_AFTER = Duration.ofHours(24);
    static final double IRRIGATION_CHANCE = 0.70;
    static final double IRRIGATION_MM = 5.0;

    // Wet grain and produce spoil in storage; even light rain matters at harvest.
    static final int HARVEST_FROM_HOUR = 6;
    static final int HARVEST_TO_HOUR = 18;
    static final double HARVEST_CHANCE = 0.60;
    static final double HARVEST_MM = 2.0;

    // Heat stress for most field crops in the dry zone.
    static final double HEAT_C = 35.0;
    static final int HEAT_LOOKAHEAD_DAYS = 3;

    // When to call it HIGH rather than MEDIUM.
    static final double HIGH_CHANCE = 0.80;
    static final double HIGH_MM = 10.0;
    static final double HIGH_WIND = 8.0;
    static final double HIGH_HEAT_C = 38.0;

    private WeatherRiskRules() {
    }

    /** The risk to a task planned for {@code at}, if any. */
    public static Optional<Risk> assess(ReminderType type, LocalDateTime at, List<ForecastSlot> slots, LocalDateTime now) {
        if (slots.isEmpty() || at.isBefore(now)) {
            return Optional.empty();
        }
        return switch (type) {
            case FERTILIZER -> washoff(at, slots);
            // Rain is the bigger problem: a sprayed field rained on is a total loss.
            case PEST_CONTROL -> washoff(at, slots).or(() -> wind(at, slots));
            case IRRIGATION -> irrigation(at, slots);
            case HARVEST -> harvest(at, slots, now);
            case OTHER -> Optional.empty();
        };
    }

    /** The first hot day within the next few days, if any. */
    public static Optional<Risk> heat(List<ForecastSlot> slots, LocalDateTime now) {
        LocalDate today = now.toLocalDate();
        LocalDate until = today.plusDays(HEAT_LOOKAHEAD_DAYS);
        return slots.stream()
            .filter(s -> s.tempMaxC() >= HEAT_C)
            .map(s -> s.start().toLocalDate())
            .filter(day -> !day.isBefore(today) && day.isBefore(until))
            .min(Comparator.naturalOrder())
            .map(day -> {
                // Reported at that day's peak, not the first slot to cross 35.
                double peak = slots.stream()
                    .filter(s -> s.start().toLocalDate().equals(day))
                    .mapToDouble(ForecastSlot::tempMaxC)
                    .max()
                    .orElse(HEAT_C);
                return new Risk(AlertType.HEAT_STRESS, peak >= HIGH_HEAT_C ? Severity.HIGH : Severity.MEDIUM,
                                day, 0, 0, 0, round1(peak), null);
            });
    }

    // ------------------------------------------------------------------ rules

    private static Optional<Risk> washoff(LocalDateTime at, List<ForecastSlot> slots) {
        Window w = Window.of(slots, at.minus(WASHOFF_BEFORE), at.plus(WASHOFF_AFTER));
        if (w.isEmpty() || !washesOff(w)) {
            return Optional.empty();
        }
        LocalDateTime suggestion = nextTime(at, slots, WASHOFF_AFTER,
            candidate -> !washesOff(Window.of(slots, candidate.minus(WASHOFF_BEFORE), candidate.plus(WASHOFF_AFTER))));
        return Optional.of(rainRisk(AlertType.RAIN_WASHOFF, w, suggestion));
    }

    private static boolean washesOff(Window w) {
        return w.maxChance >= WASHOFF_CHANCE || w.rainMm >= WASHOFF_MM;
    }

    private static Optional<Risk> wind(LocalDateTime at, List<ForecastSlot> slots) {
        Window w = Window.of(slots, at.minus(SPRAY_WINDOW), at.plus(SPRAY_WINDOW));
        if (w.isEmpty() || w.maxWind <= SPRAY_MAX_WIND) {
            return Optional.empty();
        }
        LocalDateTime suggestion = nextTime(at, slots, WASHOFF_AFTER, candidate -> {
            Window c = Window.of(slots, candidate.minus(SPRAY_WINDOW), candidate.plus(SPRAY_WINDOW));
            return c.maxWind <= SPRAY_MAX_WIND
                && !washesOff(Window.of(slots, candidate.minus(WASHOFF_BEFORE), candidate.plus(WASHOFF_AFTER)));
        });
        return Optional.of(new Risk(AlertType.SPRAY_WIND, w.maxWind >= HIGH_WIND ? Severity.HIGH : Severity.MEDIUM,
            w.windiest.start().toLocalDate(), percent(w.maxChance), round1(w.rainMm), round1(w.maxWind), 0,
            suggestion));
    }

    private static Optional<Risk> irrigation(LocalDateTime at, List<ForecastSlot> slots) {
        Window w = Window.of(slots, at, at.plus(IRRIGATION_AFTER));
        if (w.isEmpty() || !(w.maxChance >= IRRIGATION_CHANCE || w.rainMm >= IRRIGATION_MM)) {
            return Optional.empty();
        }
        // No better time to suggest: the rain is the irrigation.
        return Optional.of(rainRisk(AlertType.IRRIGATION_RAIN, w, null));
    }

    private static Optional<Risk> harvest(LocalDateTime at, List<ForecastSlot> slots, LocalDateTime now) {
        Window w = daylight(slots, at.toLocalDate());
        if (w.isEmpty() || !wetHarvest(w)) {
            return Optional.empty();
        }
        // The nearest dry day either side, preferring earlier: produce left
        // standing longer is exposed to the same weather.
        LocalDate horizon = slots.get(slots.size() - 1).start().toLocalDate();
        LocalDateTime suggestion = null;
        for (int d = 1; d <= 5 && suggestion == null; d++) {
            LocalDateTime earlier = at.minusDays(d);
            if (earlier.isAfter(now) && dryDay(slots, earlier.toLocalDate())) {
                suggestion = earlier;
            } else if (!at.toLocalDate().plusDays(d).isAfter(horizon) && dryDay(slots, at.toLocalDate().plusDays(d))) {
                suggestion = at.plusDays(d);
            }
        }
        return Optional.of(rainRisk(AlertType.HARVEST_RAIN, w, suggestion));
    }

    private static boolean wetHarvest(Window w) {
        return w.maxChance >= HARVEST_CHANCE || w.rainMm >= HARVEST_MM;
    }

    private static boolean dryDay(List<ForecastSlot> slots, LocalDate day) {
        Window w = daylight(slots, day);
        return !w.isEmpty() && !wetHarvest(w);
    }

    private static Window daylight(List<ForecastSlot> slots, LocalDate day) {
        return Window.of(slots, day.atTime(HARVEST_FROM_HOUR, 0), day.atTime(HARVEST_TO_HOUR, 0));
    }

    // ---------------------------------------------------------------- helpers

    /**
     * The same time of day on the first later day that passes, as long as the
     * forecast still covers the whole window after it. Beyond the horizon
     * nothing can be promised, so nothing is suggested.
     */
    private static LocalDateTime nextTime(LocalDateTime at, List<ForecastSlot> slots, Duration needsAfter,
                                          Predicate<LocalDateTime> passes) {
        LocalDateTime horizon = slots.get(slots.size() - 1).end();
        for (int d = 1; d <= 5; d++) {
            LocalDateTime candidate = at.plusDays(d);
            if (candidate.plus(needsAfter).isAfter(horizon)) {
                return null;
            }
            if (passes.test(candidate)) {
                return candidate;
            }
        }
        return null;
    }

    private static Risk rainRisk(AlertType type, Window w, LocalDateTime suggestion) {
        Severity severity = w.maxChance >= HIGH_CHANCE || w.rainMm >= HIGH_MM ? Severity.HIGH : Severity.MEDIUM;
        return new Risk(type, severity, w.wettest.start().toLocalDate(), percent(w.maxChance), round1(w.rainMm),
                        round1(w.maxWind), 0, suggestion);
    }

    private static int percent(double chance) {
        return (int) Math.round(chance * 100);
    }

    private static double round1(double v) {
        return Math.round(v * 10) / 10.0;
    }

    /** The slots overlapping a time range, summarised. */
    private record Window(double maxChance, double rainMm, double maxWind,
                          ForecastSlot wettest, ForecastSlot windiest) {

        static Window of(List<ForecastSlot> slots, LocalDateTime from, LocalDateTime to) {
            List<ForecastSlot> in = slots.stream().filter(s -> s.overlaps(from, to)).toList();
            if (in.isEmpty()) {
                return new Window(0, 0, 0, null, null);
            }
            ForecastSlot wettest = in.stream()
                .max(Comparator.comparingDouble(ForecastSlot::rainChance).thenComparingDouble(ForecastSlot::rainMm))
                .orElseThrow();
            ForecastSlot windiest = in.stream().max(Comparator.comparingDouble(ForecastSlot::windSpeed)).orElseThrow();
            return new Window(
                wettest.rainChance(),
                in.stream().mapToDouble(ForecastSlot::rainMm).sum(),
                windiest.windSpeed(),
                wettest,
                windiest);
        }

        boolean isEmpty() {
            return wettest == null;
        }
    }
}
