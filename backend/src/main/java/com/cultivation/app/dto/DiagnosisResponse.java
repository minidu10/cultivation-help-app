package com.cultivation.app.dto;

import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * What the crop doctor concluded about one photo.
 *
 * @param id           null when nothing was saved: a photo that is not of a
 *                     plant is answered but kept out of the crop's history
 * @param confidence   0 to 1, as the model rated itself
 * @param severity     none, low, moderate or severe
 * @param seeExpert    true for low confidence or anything severe or spreading
 * @param thumbnailUrl where to fetch the saved thumbnail (authenticated)
 */
public record DiagnosisResponse(
        Long id,
        Long cropId,
        // Pinned: a boolean record component named isX can otherwise come out as "x".
        @JsonProperty("isPlant") boolean isPlant,
        String cropGuess,
        String condition,
        double confidence,
        String severity,
        boolean seeExpert,
        List<String> symptoms,
        List<String> treatmentOrganic,
        List<String> treatmentChemical,
        List<String> prevention,
        String note,
        LocalDateTime createdAt,
        String thumbnailUrl) {
}
