package com.cultivation.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.CropInsight;

@Repository
public interface CropInsightRepository extends JpaRepository<CropInsight, Long> {
}
