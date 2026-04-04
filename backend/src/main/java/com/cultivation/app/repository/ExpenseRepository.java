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

    // Sum all expenses for a crop
    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.crop.id = :cropId")
    BigDecimal sumAmountByCropId(@Param("cropId") Long cropId);
}