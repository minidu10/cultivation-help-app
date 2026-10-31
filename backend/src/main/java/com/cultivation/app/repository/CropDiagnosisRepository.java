package com.cultivation.app.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.CropDiagnosis;

@Repository
public interface CropDiagnosisRepository extends JpaRepository<CropDiagnosis, Long> {

    List<CropDiagnosis> findByCropIdAndCropUserIdOrderByCreatedAtDesc(Long cropId, Long userId);

    Optional<CropDiagnosis> findByIdAndCropIdAndCropUserId(Long id, Long cropId, Long userId);

    /** Photos a farmer has had checked since a moment, across all their crops: the daily cap. */
    long countByCropUserIdAndCreatedAtGreaterThanEqual(Long userId, LocalDateTime since);
}
