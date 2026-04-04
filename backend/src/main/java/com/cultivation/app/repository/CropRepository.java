package com.cultivation.app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.Crop;

@Repository
public interface CropRepository extends JpaRepository<Crop, Long> {

    // Get all crops for a specific user
    List<Crop> findByUserIdOrderByCreatedAtDesc(Long userId);

    // Get one crop — but only if it belongs to this user
    Optional<Crop> findByIdAndUserId(Long id, Long userId);

    // Count crops by status for a user
    long countByUserIdAndStatus(Long userId, Crop.CropStatus status);
}