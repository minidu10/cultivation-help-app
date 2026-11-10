package com.cultivation.app.service;

import java.net.URI;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

import com.cultivation.app.config.CacheConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * The raw OpenWeather calls, each cached.
 *
 * Kept apart from WeatherService because Spring's caching works through a
 * proxy: a cached method called from inside the same class bypasses it. With
 * the HTTP calls here, every lookup WeatherService makes goes through the cache.
 */
@Component
public class OpenWeatherClient {

    private static final String CURRENT_PATH = "/data/2.5/weather";
    private static final String FORECAST_PATH = "/data/2.5/forecast";
    private static final String GEOCODE_DIRECT_PATH = "/geo/1.0/direct";

    /** The free tier's whole horizon: 5 days of 3-hourly slots. */
    public static final int MAX_FORECAST_SLOTS = 40;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${weather.openweather.base-url}")
    private String baseUrl;

    @Value("${weather.openweather.api-key:}")
    private String apiKey;

    public OpenWeatherClient(@Qualifier("openWeatherRestTemplate") RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public record GeocodedPoint(double lat, double lon, String displayName) {}

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }

    /**
     * Unknown places are cached too, as an empty result. A crop whose field
     * location is "North Field" would otherwise cost a geocoding call on
     * every single dashboard load.
     */
    @Cacheable(cacheNames = CacheConfig.GEOCODE, key = "#query.trim().toLowerCase()")
    public Optional<GeocodedPoint> geocode(String query) {
        URI uri = UriComponentsBuilder
            .fromUriString(baseUrl)
            .path(GEOCODE_DIRECT_PATH)
            .queryParam("q", query.trim())
            .queryParam("limit", 1)
            .queryParam("appid", requireKey())
            .build()
            .encode()
            .toUri();

        JsonNode root = fetch(uri, "Failed to geocode location with OpenWeather");
        if (!root.isArray() || root.isEmpty()) {
            return Optional.empty();
        }

        JsonNode first = root.get(0);
        String name = text(first.path("name"));
        String country = text(first.path("country"));
        String displayName = (country == null || country.isBlank()) ? name : name + ", " + country;
        return Optional.of(new GeocodedPoint(
            first.path("lat").asDouble(), first.path("lon").asDouble(), displayName));
    }

    @Cacheable(cacheNames = CacheConfig.WEATHER_CURRENT, key = "#lat + ':' + #lon")
    public JsonNode current(double lat, double lon) {
        return fetch(weatherUri(CURRENT_PATH, lat, lon, null), "Failed to fetch weather data from OpenWeather");
    }

    /** Always the full horizon, so one cache entry serves every caller. */
    @Cacheable(cacheNames = CacheConfig.WEATHER_FORECAST, key = "#lat + ':' + #lon")
    public JsonNode forecast(double lat, double lon) {
        return fetch(weatherUri(FORECAST_PATH, lat, lon, MAX_FORECAST_SLOTS),
                     "Failed to fetch weather data from OpenWeather");
    }

    private URI weatherUri(String path, double lat, double lon, Integer count) {
        UriComponentsBuilder builder = UriComponentsBuilder
            .fromUriString(baseUrl)
            .path(path)
            .queryParam("lat", lat)
            .queryParam("lon", lon)
            .queryParam("appid", requireKey())
            .queryParam("units", "metric");
        if (count != null) {
            builder.queryParam("cnt", count);
        }
        return builder.build().encode().toUri();
    }

    private JsonNode fetch(URI uri, String failureMessage) {
        try {
            String payload = restTemplate.getForObject(uri, String.class);
            return objectMapper.readTree(payload);
        } catch (RestClientException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, failureMessage, ex);
        } catch (JsonProcessingException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Failed to parse weather response", ex);
        }
    }

    /** 503, not 500: the server is fine, the optional integration is just off. */
    private String requireKey() {
        if (apiKey == null || apiKey.isBlank()) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Weather is not configured on this server");
        }
        return apiKey;
    }

    private static String text(JsonNode node) {
        return node == null || node.isMissingNode() || node.isNull() ? null : node.asText();
    }
}
