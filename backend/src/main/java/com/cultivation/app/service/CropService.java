package com.cultivation.app.service;

import com.cultivation.app.dto.CropRequest;
import com.cultivation.app.dto.CropResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.CropRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CropService {

    private final CropRepository cropRepository;

    public CropService(CropRepository cropRepository) {
        this.cropRepository = cropRepository;
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
                .orElseThrow(() -> new RuntimeException("Crop not found"));
        return new CropResponse(crop);
    }

    // UPDATE
    public CropResponse updateCrop(Long cropId, CropRequest request, User currentUser) {
        Crop crop = cropRepository
                .findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));

        if (request.getName() != null) crop.setName(request.getName());
        if (request.getVariety() != null) crop.setVariety(request.getVariety());
        if (request.getFieldLocation() != null) crop.setFieldLocation(request.getFieldLocation());
        if (request.getFieldSizeAcres() != null) crop.setFieldSizeAcres(request.getFieldSizeAcres());
        if (request.getPlantingDate() != null) crop.setPlantingDate(request.getPlantingDate());
        if (request.getExpectedHarvestDate() != null) crop.setExpectedHarvestDate(request.getExpectedHarvestDate());
        if (request.getNotes() != null) crop.setNotes(request.getNotes());

        Crop updated = cropRepository.save(crop);
        return new CropResponse(updated);
    }

    // DELETE
    public void deleteCrop(Long cropId, User currentUser) {
        Crop crop = cropRepository
                .findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));
        cropRepository.delete(crop);
    }
}