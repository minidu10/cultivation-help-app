package com.cultivation.app.service;

import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.cultivation.app.dto.HarvestRequest;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.Harvest;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
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

    /**
     * Saves the record, unless it is a replay of an offline write that
     * already arrived: then the original is returned. The unique index on
     * (crop_id, client_ref) settles two copies arriving at once; the loser's
     * insert fails and it returns the winner's row.
     */
    public Harvest addHarvest(Long cropId, HarvestRequest request, User currentUser) {
        Crop crop = findCrop(cropId, currentUser);
        if (request.getClientRef() != null) {
            var replay = harvestRepository.findByCropIdAndClientRef(cropId, request.getClientRef());
            if (replay.isPresent()) {
                return replay.get();
            }
        }

        Harvest harvest = new Harvest();
        harvest.setCrop(crop);
        harvest.setHarvestDate(request.getHarvestDate());
        harvest.setQuantity(request.getQuantity());
        harvest.setUnit(request.getUnit());
        harvest.setPricePerUnit(request.getPricePerUnit());
        harvest.setBuyerName(request.getBuyerName());
        harvest.setNotes(request.getNotes());
        harvest.setClientRef(request.getClientRef());

        try {
            return harvestRepository.saveAndFlush(harvest);
        } catch (DataIntegrityViolationException race) {
            if (request.getClientRef() == null) {
                throw race;
            }
            return harvestRepository.findByCropIdAndClientRef(cropId, request.getClientRef()).orElseThrow(() -> race);
        }
    }

    public List<Harvest> getHarvestsForCrop(Long cropId, User currentUser) {
        findCrop(cropId, currentUser);
        return harvestRepository.findByCropIdOrderByHarvestDateDesc(cropId);
    }

    /** Partial update: a field left out of the request keeps its value. */
    public Harvest updateHarvest(Long cropId, Long harvestId, HarvestRequest request, User currentUser) {
        Harvest harvest = findHarvest(cropId, harvestId, currentUser);

        if (request.getHarvestDate() != null) harvest.setHarvestDate(request.getHarvestDate());
        if (request.getQuantity() != null) harvest.setQuantity(request.getQuantity());
        if (request.getUnit() != null) harvest.setUnit(request.getUnit());
        if (request.getPricePerUnit() != null) harvest.setPricePerUnit(request.getPricePerUnit());
        if (request.getBuyerName() != null) harvest.setBuyerName(request.getBuyerName());
        if (request.getNotes() != null) harvest.setNotes(request.getNotes());

        return harvestRepository.save(harvest);
    }

    public void deleteHarvest(Long cropId, Long harvestId, User currentUser) {
        harvestRepository.delete(findHarvest(cropId, harvestId, currentUser));
    }

    private Crop findCrop(Long cropId, User currentUser) {
        return cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));
    }

    private Harvest findHarvest(Long cropId, Long harvestId, User currentUser) {
        return harvestRepository.findByIdAndCropIdAndCropUserId(harvestId, cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Harvest not found"));
    }
}
