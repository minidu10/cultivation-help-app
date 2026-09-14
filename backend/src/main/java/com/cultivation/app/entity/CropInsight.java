package com.cultivation.app.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

/**
 * A stored AI insight for one crop.
 *
 * The primary key is the crop id: one insight per crop, replaced in place
 * whenever the figures behind it change.
 */
@Entity
@Table(name = "crop_insights")
public class CropInsight {

    @Id
    @Column(name = "crop_id")
    private Long cropId;

    /** Digest of the figures the insight was generated from. */
    @Column(nullable = false, length = 64)
    private String fingerprint;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "generated_at", nullable = false)
    private LocalDateTime generatedAt;

    protected CropInsight() {
    }

    public CropInsight(Long cropId, String fingerprint, String content) {
        this.cropId = cropId;
        refresh(fingerprint, content);
    }

    /**
     * Replaces the stored text and stamps the time in one step.
     *
     * This was a @PreUpdate callback, which fires at flush - after the service
     * has already read generatedAt to build its response, so a freshly
     * generated insight was returned carrying the previous timestamp.
     */
    public void refresh(String fingerprint, String content) {
        this.fingerprint = fingerprint;
        this.content = content;
        this.generatedAt = LocalDateTime.now();
    }

    @PrePersist
    void prePersist() {
        if (generatedAt == null) {
            generatedAt = LocalDateTime.now();
        }
    }

    public Long getCropId() { return cropId; }

    public String getFingerprint() { return fingerprint; }

    public String getContent() { return content; }

    public LocalDateTime getGeneratedAt() { return generatedAt; }
}
