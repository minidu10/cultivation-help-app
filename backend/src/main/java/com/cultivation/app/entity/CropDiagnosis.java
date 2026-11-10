package com.cultivation.app.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

/** One photo the crop doctor looked at, and what it concluded. */
@Entity
@Table(name = "crop_diagnoses")
public class CropDiagnosis {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @Column(name = "is_plant", nullable = false)
    private Boolean plant;

    @Column(name = "crop_guess", length = 100)
    private String cropGuess;

    @Column(nullable = false, length = 100)
    private String condition;

    @Column(nullable = false)
    private Double confidence;

    @Column(nullable = false, length = 20)
    private String severity;

    @Column(name = "see_expert", nullable = false)
    private Boolean seeExpert;

    /** Symptoms, treatments and prevention as a JSON object of string lists. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false)
    private String details;

    @Column(length = 300)
    private String note;

    @Column(length = 100)
    private String model;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    public Long getId() { return id; }

    public Crop getCrop() { return crop; }
    public void setCrop(Crop crop) { this.crop = crop; }

    public Boolean getPlant() { return plant; }
    public void setPlant(Boolean plant) { this.plant = plant; }

    public String getCropGuess() { return cropGuess; }
    public void setCropGuess(String cropGuess) { this.cropGuess = cropGuess; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    public Double getConfidence() { return confidence; }
    public void setConfidence(Double confidence) { this.confidence = confidence; }

    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }

    public Boolean getSeeExpert() { return seeExpert; }
    public void setSeeExpert(Boolean seeExpert) { this.seeExpert = seeExpert; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public LocalDateTime getCreatedAt() { return createdAt; }
}
