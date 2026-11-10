package com.cultivation.app.service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.cultivation.app.dto.DailyForecastResponse;
import com.cultivation.app.dto.WeatherCurrentResponse;
import com.cultivation.app.dto.WeatherForecastItemResponse;
import com.cultivation.app.dto.WeatherForecastResponse;
import com.cultivation.app.service.OpenWeatherClient.GeocodedPoint;
import com.fasterxml.jackson.databind.JsonNode;

@Service
public class WeatherService {

    private static final String ICON_BASE_URL = "https://openweathermap.org/img/wn/";

    private final OpenWeatherClient client;

    public WeatherService(OpenWeatherClient client) {
        this.client = client;
    }

    public WeatherCurrentResponse getCurrent(Double lat, Double lon) {
        JsonNode root = client.current(round(lat), round(lon));

        WeatherCurrentResponse response = new WeatherCurrentResponse();
        response.setLocation(extractLocation(root));
        response.setTemperatureC(asDouble(root.path("main").path("temp")));
        response.setFeelsLikeC(asDouble(root.path("main").path("feels_like")));
        response.setHumidity(asInt(root.path("main").path("humidity")));
        response.setWindSpeed(asDouble(root.path("wind").path("speed")));
        response.setRainMm(asDouble(root.path("rain").path("1h")));

        JsonNode weatherNode = firstWeatherNode(root);
        response.setDescription(asText(weatherNode.path("description")));
        String icon = asText(weatherNode.path("icon"));
        response.setIconCode(icon);
        response.setIconUrl(buildIconUrl(icon));

        return response;
    }

    public WeatherCurrentResponse getCurrentByLocation(String locationQuery) {
        GeocodedPoint point = geocodeLocation(locationQuery);
        WeatherCurrentResponse response = getCurrent(point.lat(), point.lon());
        if (response.getLocation() == null || response.getLocation().isBlank()) {
            response.setLocation(point.displayName());
        }
        return response;
    }

    public WeatherForecastResponse getForecast(Double lat, Double lon, Integer count) {
        int safeCount = (count == null || count < 1) ? 5 : Math.min(count, OpenWeatherClient.MAX_FORECAST_SLOTS);
        JsonNode root = client.forecast(round(lat), round(lon));

        List<WeatherForecastItemResponse> items = new ArrayList<>();
        for (JsonNode itemNode : root.path("list")) {
            if (items.size() >= safeCount) {
                break;
            }
            WeatherForecastItemResponse item = new WeatherForecastItemResponse();
            item.setDateTime(asText(itemNode.path("dt_txt")));
            item.setTemperatureC(asDouble(itemNode.path("main").path("temp")));
            item.setHumidity(asInt(itemNode.path("main").path("humidity")));

            double pop = itemNode.path("pop").isMissingNode() ? 0.0 : itemNode.path("pop").asDouble();
            item.setRainChancePercent((int) Math.round(pop * 100));
            item.setRainMm(itemNode.path("rain").path("3h").asDouble(0));
            item.setWindSpeed(asDouble(itemNode.path("wind").path("speed")));

            JsonNode weatherNode = firstWeatherNode(itemNode);
            item.setDescription(asText(weatherNode.path("description")));
            String icon = asText(weatherNode.path("icon"));
            item.setIconCode(icon);
            item.setIconUrl(buildIconUrl(icon));
            items.add(item);
        }

        WeatherForecastResponse response = new WeatherForecastResponse();
        response.setLocation(extractLocation(root));
        response.setItems(items);
        return response;
    }

    public WeatherForecastResponse getForecastByLocation(String locationQuery, Integer count) {
        GeocodedPoint point = geocodeLocation(locationQuery);
        WeatherForecastResponse response = getForecast(point.lat(), point.lon(), count);
        if (response.getLocation() == null || response.getLocation().isBlank()) {
            response.setLocation(point.displayName());
        }
        return response;
    }

    /**
     * A real five-day forecast: the free tier's 40 three-hour slots, one row
     * per local day. The 3-hourly endpoint above only ever covered a day.
     */
    public DailyForecastResponse getDaily(Double lat, Double lon) {
        JsonNode root = client.forecast(round(lat), round(lon));
        return new DailyForecastResponse(extractLocation(root), summariseDays(ForecastSlot.parse(root, ZoneId.systemDefault())));
    }

    public DailyForecastResponse getDailyByLocation(String locationQuery) {
        GeocodedPoint point = geocodeLocation(locationQuery);
        DailyForecastResponse daily = getDaily(point.lat(), point.lon());
        return "Unknown".equals(daily.location()) ? new DailyForecastResponse(point.displayName(), daily.days()) : daily;
    }

    /** Forecast slots for a place, in local time. For the alert rules. */
    public List<ForecastSlot> slotsFor(GeocodedPoint point) {
        return ForecastSlot.parse(client.forecast(round(point.lat()), round(point.lon())), ZoneId.systemDefault());
    }

    /** Like geocoding for the endpoints, but an unknown place is empty rather than a 404. */
    public Optional<GeocodedPoint> resolve(String locationQuery) {
        if (locationQuery == null || locationQuery.isBlank() || !client.isConfigured()) {
            return Optional.empty();
        }
        return client.geocode(locationQuery);
    }

    static List<DailyForecastResponse.Day> summariseDays(List<ForecastSlot> slots) {
        Map<LocalDate, List<ForecastSlot>> byDay = new LinkedHashMap<>();
        for (ForecastSlot slot : slots) {
            byDay.computeIfAbsent(slot.start().toLocalDate(), d -> new ArrayList<>()).add(slot);
        }
        List<DailyForecastResponse.Day> days = new ArrayList<>();
        for (Map.Entry<LocalDate, List<ForecastSlot>> entry : byDay.entrySet()) {
            List<ForecastSlot> day = entry.getValue();
            // The description and icon come from the slot nearest midday,
            // which is what "the weather tomorrow" means to most people.
            ForecastSlot midday = day.stream()
                .min(Comparator.comparingInt(s -> Math.abs(s.start().getHour() - 12)))
                .orElseThrow();
            days.add(new DailyForecastResponse.Day(
                entry.getKey(),
                round1(day.stream().mapToDouble(ForecastSlot::tempC).min().orElse(0)),
                round1(day.stream().mapToDouble(ForecastSlot::tempMaxC).max().orElse(0)),
                round1(day.stream().mapToDouble(ForecastSlot::rainMm).sum()),
                (int) Math.round(100 * day.stream().mapToDouble(ForecastSlot::rainChance).max().orElse(0)),
                round1(day.stream().mapToDouble(ForecastSlot::windSpeed).max().orElse(0)),
                midday.description(),
                buildIconUrl(midday.iconCode())));
        }
        return days;
    }

    private static double round1(double v) {
        return Math.round(v * 10) / 10.0;
    }

    private GeocodedPoint geocodeLocation(String locationQuery) {
        if (locationQuery == null || locationQuery.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Location is required");
        }
        return client.geocode(locationQuery)
            .orElseThrow(() -> new ResponseStatusException(
                HttpStatus.NOT_FOUND, "Location not found: " + locationQuery));
    }

    /**
     * Two decimal places is about a kilometre: finer than any forecast grid,
     * and it lets neighbouring fields share one cache entry.
     */
    private static double round(Double coordinate) {
        if (coordinate == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Latitude and longitude are required");
        }
        return Math.round(coordinate * 100.0) / 100.0;
    }

    private static JsonNode firstWeatherNode(JsonNode root) {
        JsonNode weatherArray = root.path("weather");
        if (weatherArray.isArray() && weatherArray.size() > 0) {
            return weatherArray.get(0);
        }
        return root.path("weather");
    }

    private static String extractLocation(JsonNode root) {
        String city = asText(root.path("name"));
        if (city == null || city.isBlank()) {
            city = asText(root.path("city").path("name"));
        }
        String country = asText(root.path("city").path("country"));
        if (country == null || country.isBlank()) {
            country = asText(root.path("sys").path("country"));
        }

        if (city == null || city.isBlank()) {
            return country == null ? "Unknown" : country;
        }

        if (country == null || country.isBlank()) {
            return city;
        }

        return city + ", " + country;
    }

    private static String buildIconUrl(String iconCode) {
        if (iconCode == null || iconCode.isBlank()) {
            return null;
        }
        return ICON_BASE_URL + iconCode + "@2x.png";
    }

    private static String asText(JsonNode node) {
        return node == null || node.isMissingNode() || node.isNull() ? null : node.asText();
    }

    private static Double asDouble(JsonNode node) {
        return node == null || node.isMissingNode() || node.isNull() ? null : node.asDouble();
    }

    private static Integer asInt(JsonNode node) {
        return node == null || node.isMissingNode() || node.isNull() ? null : node.asInt();
    }
}
