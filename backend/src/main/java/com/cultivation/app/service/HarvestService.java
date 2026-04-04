package com.cultivation.app.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.cultivation.app.dto.HarvestRequest;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.Harvest;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.HarvestRepository;

@Service
public class HarvestService {

    private final HarvestRepository harvestRepository;
    private final CropRepository cropRepository;

    public HarvestService(HarvestRepository harvestRepository,
                          CropRepository cropRepository) {
        this.harvestRepository = harvestRepository;
        this.cropRepository = cropRepository;
    }

    public Harvest addHarvest(Long cropId, HarvestRequest request, User currentUser) {
        Crop crop = cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));

        Harvest harvest = new Harvest();
        harvest.setCrop(crop);
        harvest.setHarvestDate(request.getHarvestDate());
        harvest.setQuantity(request.getQuantity());
        harvest.setUnit(request.getUnit());
        harvest.setPricePerUnit(request.getPricePerUnit());
        harvest.setBuyerName(request.getBuyerName());
        harvest.setNotes(request.getNotes());

        return harvestRepository.save(harvest);
    }

    public List<Harvest> getHarvestsForCrop(Long cropId, User currentUser) {
        cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));
        return harvestRepository.findByCropIdOrderByHarvestDateDesc(cropId);
    }

    public void deleteHarvest(Long harvestId, User currentUser) {
        Harvest harvest = harvestRepository
                .findByIdAndCropUserId(harvestId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Harvest not found"));
        harvestRepository.delete(harvest);
    }
}