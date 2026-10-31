package com.cultivation.app.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.Expense;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    List<Expense> findByCropIdOrderByExpenseDateDesc(Long cropId);

    Optional<Expense> findByIdAndCropUserId(Long id, Long userId);

    /** Scoped to the crop in the URL as well as the owner, so a path cannot name the wrong crop. */
    Optional<Expense> findByIdAndCropIdAndCropUserId(Long id, Long cropId, Long userId);

    /**
     * Expense total per crop for one farmer, in a single grouped query. The
     * dashboard used to ask once per crop; this is one round trip for all of them.
     * Rows are [cropId, total].
     */
    @Query("SELECT e.crop.id, COALESCE(SUM(e.amount), 0) FROM Expense e "
         + "WHERE e.crop.user.id = :userId GROUP BY e.crop.id")
    List<Object[]> sumAmountPerCropForUser(@Param("userId") Long userId);

    // Sum all expenses for a crop
    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.crop.id = :cropId")
    BigDecimal sumAmountByCropId(@Param("cropId") Long cropId);
}