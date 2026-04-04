package com.cultivation.app.controller;

import com.cultivation.app.dto.CropRequest;
import com.cultivation.app.dto.CropResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.CropService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/crops")
public class CropController {

    private final CropService cropService;

    public CropController(CropService cropService) {
        this.cropService = cropService;
    }

    @PostMapping
    public ResponseEntity<CropResponse> createCrop(
            @RequestBody CropRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.createCrop(request, currentUser));
    }

    @GetMapping
    public ResponseEntity<List<CropResponse>> getMyCrops(
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.getMyCrops(currentUser));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CropResponse> getCrop(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.getCropById(id, currentUser));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CropResponse> updateCrop(
            @PathVariable Long id,
            @RequestBody CropRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(cropService.updateCrop(id, request, currentUser));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCrop(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        cropService.deleteCrop(id, currentUser);
        return ResponseEntity.noContent().build();
    }
}