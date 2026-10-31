package com.cultivation.app.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

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
