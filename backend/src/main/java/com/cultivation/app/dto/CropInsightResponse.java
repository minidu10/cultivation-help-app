package com.cultivation.app.dto;

import java.time.LocalDateTime;

public class CropInsightResponse {

    private final Long cropId;
    private final String cropName;
    private final String insights;
    private final LocalDateTime generatedAt;
    /** False when the text came from cache, so no tokens were spent. */
    private final boolean freshlyGenerated;

    public CropInsightResponse(Long cropId, String cropName, String insights,
                               LocalDateTime generatedAt, boolean freshlyGenerated) {
        this.cropId = cropId;
        this.cropName = cropName;
        this.insights = insights;
        this.generatedAt = generatedAt;
        this.freshlyGenerated = freshlyGenerated;
    }

    public Long getCropId() { return cropId; }
    public String getCropName() { return cropName; }
    public String getInsights() { return insights; }
    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public boolean isFreshlyGenerated() { return freshlyGenerated; }
}
