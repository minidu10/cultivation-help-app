package com.cultivation.app.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.Harvest;

@Repository
public interface HarvestRepository extends JpaRepository<Harvest, Long> {

    List<Harvest> findByCropIdOrderByHarvestDateDesc(Long cropId);

    Optional<Harvest> findByIdAndCropUserId(Long id, Long userId);

    // Sum total revenue for a crop
    @Query("SELECT COALESCE(SUM(h.quantity * h.pricePerUnit), 0) FROM Harvest h WHERE h.crop.id = :cropId")
    BigDecimal sumRevenueByCropId(@Param("cropId") Long cropId);
}