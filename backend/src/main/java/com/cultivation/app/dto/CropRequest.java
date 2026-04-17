package com.cultivation.app.dto;

import java.time.LocalDate;

import com.cultivation.app.entity.Crop;

public class CropRequest {

    private String name;
    private String variety;
    private String fieldLocation;
    private Double fieldSizeAcres;
    private LocalDate plantingDate;
    private LocalDate expectedHarvestDate;
    private Crop.CropStatus status;
    private Boolean aiInsightsEnabled;
    private String notes;

    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getVariety() { return variety; }
    public void setVariety(String variety) { this.variety = variety; }

    public String getFieldLocation() { return fieldLocation; }
    public void setFieldLocation(String fieldLocation) { this.fieldLocation = fieldLocation; }

    public Double getFieldSizeAcres() { return fieldSizeAcres; }
    public void setFieldSizeAcres(Double fieldSizeAcres) { this.fieldSizeAcres = fieldSizeAcres; }

    public LocalDate getPlantingDate() { return plantingDate; }
    public void setPlantingDate(LocalDate plantingDate) { this.plantingDate = plantingDate; }

    public LocalDate getExpectedHarvestDate() { return expectedHarvestDate; }
    public void setExpectedHarvestDate(LocalDate expectedHarvestDate) { this.expectedHarvestDate = expectedHarvestDate; }

    public Crop.CropStatus getStatus() { return status; }
    public void setStatus(Crop.CropStatus status) { this.status = status; }

    public Boolean getAiInsightsEnabled() { return aiInsightsEnabled; }
    public void setAiInsightsEnabled(Boolean aiInsightsEnabled) { this.aiInsightsEnabled = aiInsightsEnabled; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}