package com.cultivation.app.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.cultivation.app.entity.Crop;

public class CropResponse {

    private Long id;
    private String name;
    private String variety;
    private String fieldLocation;
    private Double fieldSizeAcres;
    private LocalDate plantingDate;
    private LocalDate expectedHarvestDate;
    private Crop.CropStatus status;
    private Boolean aiInsightsEnabled;
    private String notes;
    private LocalDateTime createdAt;

    // Constructor
    public CropResponse(Crop crop) {
        this.id = crop.getId();
        this.name = crop.getName();
        this.variety = crop.getVariety();
        this.fieldLocation = crop.getFieldLocation();
        this.fieldSizeAcres = crop.getFieldSizeAcres();
        this.plantingDate = crop.getPlantingDate();
        this.expectedHarvestDate = crop.getExpectedHarvestDate();
        this.status = crop.getStatus();
        this.aiInsightsEnabled = crop.getAiInsightsEnabled();
        this.notes = crop.getNotes();
        this.createdAt = crop.getCreatedAt();
    }

    // Getters
    public Long getId() { return id; }
    public String getName() { return name; }
    public String getVariety() { return variety; }
    public String getFieldLocation() { return fieldLocation; }
    public Double getFieldSizeAcres() { return fieldSizeAcres; }
    public LocalDate getPlantingDate() { return plantingDate; }
    public LocalDate getExpectedHarvestDate() { return expectedHarvestDate; }
    public Crop.CropStatus getStatus() { return status; }
    public Boolean getAiInsightsEnabled() { return aiInsightsEnabled; }
    public String getNotes() { return notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}