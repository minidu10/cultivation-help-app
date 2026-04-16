package com.cultivation.app.service;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

import com.cultivation.app.dto.WeatherCurrentResponse;
import com.cultivation.app.dto.WeatherForecastItemResponse;
import com.cultivation.app.dto.WeatherForecastResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class WeatherService {

    private static final String CURRENT_PATH = "/data/2.5/weather";
    private static final String FORECAST_PATH = "/data/2.5/forecast";
    private static final String GEOCODE_DIRECT_PATH = "/geo/1.0/direct";
    private static final String ICON_BASE_URL = "https://openweathermap.org/img/wn/";

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${weather.openweather.base-url}")
    private String baseUrl;

    @Value("${weather.openweather.api-key:}")
    private String apiKey;

    public WeatherService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    public WeatherCurrentResponse getCurrent(Double lat, Double lon) {
        JsonNode root = fetchWeatherJson(CURRENT_PATH, lat, lon, null);

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
        if (locationQuery == null || locationQuery.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Location is required");
        }

        GeocodedPoint point = geocodeLocation(locationQuery);
        WeatherCurrentResponse response = getCurrent(point.lat(), point.lon());
        if (response.getLocation() == null || response.getLocation().isBlank()) {
            response.setLocation(point.displayName());
        }
        return response;
    }

    public WeatherForecastResponse getForecast(Double lat, Double lon, Integer count) {
        Integer safeCount = (count == null || count < 1) ? 5 : Math.min(count, 40);
        JsonNode root = fetchWeatherJson(FORECAST_PATH, lat, lon, safeCount);

        List<WeatherForecastItemResponse> items = new ArrayList<>();
        for (JsonNode itemNode : root.path("list")) {
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

    private JsonNode fetchWeatherJson(String path, Double lat, Double lon, Integer count) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Weather API key is not configured"
            );
        }

        URI uri = buildUri(path, lat, lon, count);
        try {
            String payload = restTemplate.getForObject(uri, String.class);
            return objectMapper.readTree(payload);
        } catch (RestClientException ex) {
            throw new ResponseStatusException(
                HttpStatus.BAD_GATEWAY,
                "Failed to fetch weather data from OpenWeather",
                ex
            );
        } catch (JsonProcessingException ex) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Failed to parse weather response",
                ex
            );
        }
    }

    private GeocodedPoint geocodeLocation(String locationQuery) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Weather API key is not configured"
            );
        }

        URI uri = UriComponentsBuilder
            .fromUriString(baseUrl)
            .path(GEOCODE_DIRECT_PATH)
            .queryParam("q", locationQuery)
            .queryParam("limit", 1)
            .queryParam("appid", apiKey)
            .build(true)
            .toUri();

        try {
            String payload = restTemplate.getForObject(uri, String.class);
            JsonNode root = objectMapper.readTree(payload);
            if (!root.isArray() || root.isEmpty()) {
                throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Location not found: " + locationQuery
                );
            }

            JsonNode first = root.get(0);
            double lat = first.path("lat").asDouble();
            double lon = first.path("lon").asDouble();
            String name = asText(first.path("name"));
            String country = asText(first.path("country"));
            String displayName = (country == null || country.isBlank()) ? name : name + ", " + country;
            return new GeocodedPoint(lat, lon, displayName);
        } catch (RestClientException ex) {
            throw new ResponseStatusException(
                HttpStatus.BAD_GATEWAY,
                "Failed to geocode location with OpenWeather",
                ex
            );
        } catch (JsonProcessingException ex) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Failed to parse geocoding response",
                ex
            );
        }
    }

    private URI buildUri(String path, Double lat, Double lon, Integer count) {
        UriComponentsBuilder builder = UriComponentsBuilder
            .fromUriString(baseUrl)
            .path(path)
            .queryParam("lat", lat)
            .queryParam("lon", lon)
            .queryParam("appid", apiKey)
            .queryParam("units", "metric");

        if (count != null) {
            builder.queryParam("cnt", count);
        }

        return builder.build(true).toUri();
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

    private record GeocodedPoint(double lat, double lon, String displayName) {}
}
