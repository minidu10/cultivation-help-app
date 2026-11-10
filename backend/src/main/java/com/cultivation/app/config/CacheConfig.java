package com.cultivation.app.config;

import java.time.Duration;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.github.benmanes.caffeine.cache.Caffeine;

/**
 * In-memory caches for OpenWeather lookups.
 *
 * The dashboard asks for weather per field on every load, and the free
 * OpenWeather tier is metered per call. Forecasts are only regenerated every
 * few hours upstream, so serving a 30 minute old copy loses nothing. Lifetimes
 * differ by how fast the data actually changes: a village does not move, the
 * current temperature does.
 */
@Configuration
@EnableCaching
public class CacheConfig {

    public static final String GEOCODE = "geocode";
    public static final String WEATHER_CURRENT = "weatherCurrent";
    public static final String WEATHER_FORECAST = "weatherForecast";

    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager manager = new CaffeineCacheManager();
        manager.registerCustomCache(GEOCODE, Caffeine.newBuilder()
            .expireAfterWrite(Duration.ofHours(24))
            .maximumSize(2_000)
            .build());
        manager.registerCustomCache(WEATHER_CURRENT, Caffeine.newBuilder()
            .expireAfterWrite(Duration.ofMinutes(10))
            .maximumSize(500)
            .build());
        manager.registerCustomCache(WEATHER_FORECAST, Caffeine.newBuilder()
            .expireAfterWrite(Duration.ofMinutes(30))
            .maximumSize(500)
            .build());
        return manager;
    }
}
