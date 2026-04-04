package com.cultivation.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.HarvestRequest;
import com.cultivation.app.entity.Harvest;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.HarvestService;

@RestController
@RequestMapping("/api/crops/{cropId}/harvests")
public class HarvestController {

    private final HarvestService harvestService;

    public HarvestController(HarvestService harvestService) {
        this.harvestService = harvestService;
    }

    @PostMapping
    public ResponseEntity<Harvest> addHarvest(
            @PathVariable Long cropId,
            @RequestBody HarvestRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(harvestService.addHarvest(cropId, request, currentUser));
    }

    @GetMapping
    public ResponseEntity<List<Harvest>> getHarvests(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(harvestService.getHarvestsForCrop(cropId, currentUser));
    }

    @DeleteMapping("/{harvestId}")
    public ResponseEntity<Void> deleteHarvest(
            @PathVariable Long cropId,
            @PathVariable Long harvestId,
            @AuthenticationPrincipal User currentUser) {
        harvestService.deleteHarvest(harvestId, currentUser);
        return ResponseEntity.noContent().build();
    }
}