package com.cultivation.app.controller;

import java.io.IOException;
import java.time.Duration;
import java.util.List;

import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.cultivation.app.dto.DiagnosisResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.DiagnosisService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/crops/{cropId}/diagnoses")
@Tag(name = "Crop doctor", description = "Diagnose a crop problem from a photo")
public class DiagnosisController {

    private final DiagnosisService diagnosisService;

    public DiagnosisController(DiagnosisService diagnosisService) {
        this.diagnosisService = diagnosisService;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Check a photo of the crop (JPEG or PNG, up to 5 MB)")
    public ResponseEntity<DiagnosisResponse> diagnose(
            @PathVariable Long cropId,
            @RequestPart("image") MultipartFile image,
            @RequestParam(value = "note", required = false) String note,
            @AuthenticationPrincipal User currentUser) throws IOException {
        return ResponseEntity.ok(diagnosisService.diagnose(cropId, image.getBytes(), note, currentUser));
    }

    @GetMapping
    @Operation(summary = "Every photo checked for this crop, newest first")
    public ResponseEntity<List<DiagnosisResponse>> history(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(diagnosisService.history(cropId, currentUser));
    }

    @GetMapping("/{diagnosisId}")
    @Operation(summary = "One diagnosis")
    public ResponseEntity<DiagnosisResponse> get(
            @PathVariable Long cropId,
            @PathVariable Long diagnosisId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(diagnosisService.get(cropId, diagnosisId, currentUser));
    }

    /** The stored thumbnail. Private caching: it is the farmer's own photo. */
    @GetMapping(value = "/{diagnosisId}/thumbnail", produces = MediaType.IMAGE_JPEG_VALUE)
    @Operation(summary = "The thumbnail the diagnosis was made from")
    public ResponseEntity<byte[]> thumbnail(
            @PathVariable Long cropId,
            @PathVariable Long diagnosisId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok()
            .cacheControl(CacheControl.maxAge(Duration.ofDays(7)).cachePrivate())
            .contentType(MediaType.IMAGE_JPEG)
            .body(diagnosisService.thumbnail(cropId, diagnosisId, currentUser));
    }

    @DeleteMapping("/{diagnosisId}")
    @Operation(summary = "Delete a diagnosis and its photo")
    public ResponseEntity<Void> delete(
            @PathVariable Long cropId,
            @PathVariable Long diagnosisId,
            @AuthenticationPrincipal User currentUser) {
        diagnosisService.delete(cropId, diagnosisId, currentUser);
        return ResponseEntity.noContent().build();
    }
}
