package com.cultivation.app.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.DashboardSummaryResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.DashboardService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/dashboard")
@Tag(name = "Dashboard", description = "Aggregated figures for the home screen")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/summary")
    @Operation(summary = "Totals, per-crop profit/loss and reminders in one call")
    public ResponseEntity<DashboardSummaryResponse> summary(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(dashboardService.summary(currentUser));
    }
}
