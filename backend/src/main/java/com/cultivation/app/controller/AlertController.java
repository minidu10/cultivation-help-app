package com.cultivation.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.WeatherAlertResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.WeatherAlertService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Kept apart from the dashboard summary on purpose: that call must stay fast
 * and never fail because of weather, so clients fetch alerts alongside it.
 */
@RestController
@RequestMapping("/api/alerts")
@Tag(name = "Weather alerts", description = "Planned tasks the forecast puts at risk")
public class AlertController {

    private final WeatherAlertService weatherAlertService;

    public AlertController(WeatherAlertService weatherAlertService) {
        this.weatherAlertService = weatherAlertService;
    }

    @GetMapping
    @Operation(summary = "Weather risks to my reminders and fields over the next five days")
    public ResponseEntity<List<WeatherAlertResponse>> alerts(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(weatherAlertService.alertsFor(currentUser));
    }
}
