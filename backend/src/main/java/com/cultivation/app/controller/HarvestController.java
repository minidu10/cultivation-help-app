package com.cultivation.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.HarvestRequest;
import com.cultivation.app.dto.HarvestResponse;
import com.cultivation.app.dto.OnCreate;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.HarvestService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/crops/{cropId}/harvests")
@Tag(name = "Harvests", description = "Record harvest data and revenue")
public class HarvestController {

    private final HarvestService harvestService;

    public HarvestController(HarvestService harvestService) {
        this.harvestService = harvestService;
    }

    @PostMapping
    @Operation(summary = "Add a harvest record")
    public ResponseEntity<HarvestResponse> addHarvest(
            @PathVariable Long cropId,
            @Validated(OnCreate.class) @RequestBody HarvestRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(
                HarvestResponse.fromEntity(harvestService.addHarvest(cropId, request, currentUser))
        );
    }

    @GetMapping
    @Operation(summary = "Get all harvests for a crop")
    public ResponseEntity<List<HarvestResponse>> getHarvests(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(
                harvestService.getHarvestsForCrop(cropId, currentUser)
                        .stream()
                        .map(HarvestResponse::fromEntity)
                        .toList()
        );
    }

    @PutMapping("/{harvestId}")
    @Operation(summary = "Update a harvest record (fields left out are unchanged)")
    public ResponseEntity<HarvestResponse> updateHarvest(
            @PathVariable Long cropId,
            @PathVariable Long harvestId,
            @Valid @RequestBody HarvestRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(HarvestResponse.fromEntity(
                harvestService.updateHarvest(cropId, harvestId, request, currentUser)));
    }

    @DeleteMapping("/{harvestId}")
    @Operation(summary = "Delete a harvest record")
    public ResponseEntity<Void> deleteHarvest(
            @PathVariable Long cropId,
            @PathVariable Long harvestId,
            @AuthenticationPrincipal User currentUser) {
        harvestService.deleteHarvest(cropId, harvestId, currentUser);
        return ResponseEntity.noContent().build();
    }
}