package com.cultivation.app.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.Harvest;

@Repository
public interface HarvestRepository extends JpaRepository<Harvest, Long> {

    List<Harvest> findByCropIdOrderByHarvestDateDesc(Long cropId);

    Optional<Harvest> findByIdAndCropUserId(Long id, Long userId);

    /** Scoped to the crop in the URL as well as the owner, so a path cannot name the wrong crop. */
    /** An offline write that already arrived, if this is a replay of it. */
    Optional<Harvest> findByCropIdAndClientRef(Long cropId, UUID clientRef);

    Optional<Harvest> findByIdAndCropIdAndCropUserId(Long id, Long cropId, Long userId);

    /** Revenue per crop for one farmer in a single grouped query. Rows are [cropId, total]. */
    @Query("SELECT h.crop.id, COALESCE(SUM(h.quantity * h.pricePerUnit), 0) FROM Harvest h "
         + "WHERE h.crop.user.id = :userId GROUP BY h.crop.id")
    List<Object[]> sumRevenuePerCropForUser(@Param("userId") Long userId);

    // Sum total revenue for a crop
    @Query("SELECT COALESCE(SUM(h.quantity * h.pricePerUnit), 0) FROM Harvest h WHERE h.crop.id = :cropId")
    BigDecimal sumRevenueByCropId(@Param("cropId") Long cropId);
}