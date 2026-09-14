package com.cultivation.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.CropInsightResponse;
import com.cultivation.app.dto.CropRequest;
import com.cultivation.app.dto.CropResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.CropInsightService;
import com.cultivation.app.service.CropService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/crops")
@Tag(name = "Crops", description = "Manage farming crop cycles")
public class CropController {

    private final CropService cropService;
    private final CropInsightService cropInsightService;

    public CropController(CropService cropService, CropInsightService cropInsightService) {
        this.cropInsightService = cropInsightService;
        this.cropService = cropService;
    }

    @PostMapping
    @Operation(summary = "Create a new crop")
    public ResponseEntity<CropResponse> createCrop(
            @RequestBody CropRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.createCrop(request, currentUser));
    }

    @GetMapping
    @Operation(summary = "Get all my crops")
    public ResponseEntity<List<CropResponse>> getMyCrops(
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.getMyCrops(currentUser));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a crop by ID")
    public ResponseEntity<CropResponse> getCrop(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.getCropById(id, currentUser));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a crop")
    public ResponseEntity<CropResponse> updateCrop(
            @PathVariable Long id,
            @RequestBody CropRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.updateCrop(id, request, currentUser));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a crop")
    public ResponseEntity<Void> deleteCrop(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        cropService.deleteCrop(id, currentUser);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/insights")
    @Operation(summary = "AI insight for a crop, regenerated only when its figures change")
    public ResponseEntity<CropInsightResponse> insights(
            @PathVariable Long id,
            @RequestParam(name = "refresh", defaultValue = "false") boolean refresh,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropInsightService.getInsight(id, currentUser, refresh));
    }
}
