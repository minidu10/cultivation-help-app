package com.cultivation.app.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "crops")
public class Crop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 100)
    private String variety;

    @Column(name = "field_location", length = 200)
    private String fieldLocation;

    @Column(name = "field_size_acres")
    private Double fieldSizeAcres;

    @Column(name = "planting_date", nullable = false)
    private LocalDate plantingDate;

    @Column(name = "expected_harvest_date")
    private LocalDate expectedHarvestDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CropStatus status = CropStatus.PLANTED;

    @Column(name = "ai_insights_enabled", nullable = false)
    private Boolean aiInsightsEnabled = true;

    @Column(length = 500)
    private String notes;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public enum CropStatus {
        PLANTED, GROWING, READY_TO_HARVEST, HARVESTED, FAILED
    }

    // --- Getters and Setters ---
    public Long getId() { return id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

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

    public CropStatus getStatus() { return status; }
    public void setStatus(CropStatus status) { this.status = status; }

    public Boolean getAiInsightsEnabled() { return aiInsightsEnabled; }
    public void setAiInsightsEnabled(Boolean aiInsightsEnabled) { this.aiInsightsEnabled = aiInsightsEnabled; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
}