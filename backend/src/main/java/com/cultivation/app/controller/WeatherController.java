package com.cultivation.app.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.WeatherCurrentResponse;
import com.cultivation.app.dto.WeatherForecastResponse;
import com.cultivation.app.service.WeatherService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/weather")
@Tag(name = "Weather", description = "OpenWeather-powered farm weather insights")
public class WeatherController {

    private final WeatherService weatherService;

    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping("/current")
    @Operation(summary = "Get current weather by coordinates")
    public ResponseEntity<WeatherCurrentResponse> getCurrent(
            @RequestParam Double lat,
            @RequestParam Double lon) {
        return ResponseEntity.ok(weatherService.getCurrent(lat, lon));
    }

    @GetMapping("/current/by-location")
    @Operation(summary = "Get current weather by location name")
    public ResponseEntity<WeatherCurrentResponse> getCurrentByLocation(
            @RequestParam String location) {
        return ResponseEntity.ok(weatherService.getCurrentByLocation(location));
    }

    @GetMapping("/forecast")
    @Operation(summary = "Get short forecast by coordinates")
    public ResponseEntity<WeatherForecastResponse> getForecast(
            @RequestParam Double lat,
            @RequestParam Double lon,
            @RequestParam(defaultValue = "5") Integer count) {
        return ResponseEntity.ok(weatherService.getForecast(lat, lon, count));
    }
}
