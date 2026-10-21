package com.cultivation.app.dto;

import java.time.LocalDate;

import com.cultivation.app.entity.Crop;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public class CropRequest {

    @NotBlank(groups = OnCreate.class, message = "Crop name is required")
    @Size(max = 100, message = "Crop name must be at most 100 characters")
    private String name;

    @Size(max = 100, message = "Variety must be at most 100 characters")
    private String variety;

    @Size(max = 200, message = "Field location must be at most 200 characters")
    private String fieldLocation;

    @Positive(message = "Field size must be greater than zero")
    @DecimalMax(value = "100000", message = "Field size looks too large")
    private Double fieldSizeAcres;

    @NotNull(groups = OnCreate.class, message = "Planting date is required")
    private LocalDate plantingDate;

    private LocalDate expectedHarvestDate;
    private Crop.CropStatus status;
    private Boolean aiInsightsEnabled;

    @Size(max = 500, message = "Notes must be at most 500 characters")
    private String notes;

    /** Only checked when both dates are in the request. */
    @AssertTrue(message = "Expected harvest date cannot be before the planting date")
    public boolean isHarvestAfterPlanting() {
        return plantingDate == null || expectedHarvestDate == null
            || !expectedHarvestDate.isBefore(plantingDate);
    }

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
