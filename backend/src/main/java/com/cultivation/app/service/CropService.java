package com.cultivation.app.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.cultivation.app.dto.CropRequest;
import com.cultivation.app.dto.CropResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.ReminderRepository;

@Service
public class CropService {

    private final CropRepository cropRepository;
    private final ReminderRepository reminderRepository;

    public CropService(CropRepository cropRepository, ReminderRepository reminderRepository) {
        this.cropRepository = cropRepository;
        this.reminderRepository = reminderRepository;
    }

    // CREATE
    public CropResponse createCrop(CropRequest request, User currentUser) {
        Crop crop = new Crop();
        crop.setUser(currentUser);
        crop.setName(request.getName());
        crop.setVariety(request.getVariety());
        crop.setFieldLocation(request.getFieldLocation());
        crop.setFieldSizeAcres(request.getFieldSizeAcres());
        crop.setPlantingDate(request.getPlantingDate());
        crop.setExpectedHarvestDate(request.getExpectedHarvestDate());
        if (request.getStatus() != null) crop.setStatus(request.getStatus());
        if (request.getAiInsightsEnabled() != null) crop.setAiInsightsEnabled(request.getAiInsightsEnabled());
        crop.setNotes(request.getNotes());

        Crop saved = cropRepository.save(crop);
        return new CropResponse(saved);
    }

    // READ ALL
    public List<CropResponse> getMyCrops(User currentUser) {
        return cropRepository
                .findByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(CropResponse::new)
                .collect(Collectors.toList());
    }

    // READ ONE
    public CropResponse getCropById(Long cropId, User currentUser) {
        Crop crop = cropRepository
                .findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));
        return new CropResponse(crop);
    }

    // UPDATE
    public CropResponse updateCrop(Long cropId, CropRequest request, User currentUser) {
        Crop crop = cropRepository
                .findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));

        if (request.getName() != null) crop.setName(request.getName());
        if (request.getVariety() != null) crop.setVariety(request.getVariety());
        if (request.getFieldLocation() != null) crop.setFieldLocation(request.getFieldLocation());
        if (request.getFieldSizeAcres() != null) crop.setFieldSizeAcres(request.getFieldSizeAcres());
        if (request.getPlantingDate() != null) crop.setPlantingDate(request.getPlantingDate());
        if (request.getExpectedHarvestDate() != null) crop.setExpectedHarvestDate(request.getExpectedHarvestDate());
        if (request.getStatus() != null) crop.setStatus(request.getStatus());
        if (request.getAiInsightsEnabled() != null) crop.setAiInsightsEnabled(request.getAiInsightsEnabled());
        if (request.getNotes() != null) crop.setNotes(request.getNotes());

        Crop updated = cropRepository.save(crop);
        return new CropResponse(updated);
    }

    // DELETE
    public void deleteCrop(Long cropId, User currentUser) {
        Crop crop = cropRepository
                .findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));
        reminderRepository.deleteByCropIdAndCropUserId(cropId, currentUser.getId());
        cropRepository.delete(crop);
    }
}