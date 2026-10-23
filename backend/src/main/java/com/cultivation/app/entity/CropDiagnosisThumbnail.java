package com.cultivation.app.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** The small JPEG a diagnosis was made from, kept apart from the text so lists stay light. */
@Entity
@Table(name = "crop_diagnosis_thumbnails")
public class CropDiagnosisThumbnail {

    @Id
    @Column(name = "diagnosis_id")
    private Long diagnosisId;

    @Column(nullable = false)
    private byte[] image;

    protected CropDiagnosisThumbnail() {
    }

    public CropDiagnosisThumbnail(Long diagnosisId, byte[] image) {
        this.diagnosisId = diagnosisId;
        this.image = image;
    }

    public Long getDiagnosisId() { return diagnosisId; }

    public byte[] getImage() { return image; }
}
