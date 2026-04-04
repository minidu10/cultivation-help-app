package com.cultivation.app.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Service;

import com.cultivation.app.dto.ExpenseRequest;
import com.cultivation.app.dto.ProfitLossResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.Expense;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.ExpenseRepository;
import com.cultivation.app.repository.HarvestRepository;

@Service
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final CropRepository cropRepository;
    private final HarvestRepository harvestRepository;

    public ExpenseService(ExpenseRepository expenseRepository,
                          CropRepository cropRepository,
                          HarvestRepository harvestRepository) {
        this.expenseRepository = expenseRepository;
        this.cropRepository = cropRepository;
        this.harvestRepository = harvestRepository;
    }

    public Expense addExpense(Long cropId, ExpenseRequest request, User currentUser) {
        Crop crop = cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));

        Expense expense = new Expense();
        expense.setCrop(crop);
        expense.setCategory(request.getCategory());
        expense.setDescription(request.getDescription());
        expense.setAmount(request.getAmount());
        expense.setExpenseDate(request.getExpenseDate());
        expense.setNotes(request.getNotes());

        return expenseRepository.save(expense);
    }

    public List<Expense> getExpensesForCrop(Long cropId, User currentUser) {
        // Verify crop belongs to user
        cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));
        return expenseRepository.findByCropIdOrderByExpenseDateDesc(cropId);
    }

    public void deleteExpense(Long expenseId, User currentUser) {
        Expense expense = expenseRepository
                .findByIdAndCropUserId(expenseId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        expenseRepository.delete(expense);
    }

    // THE KEY METHOD — Profit/Loss calculation
    public ProfitLossResponse calculateProfitLoss(Long cropId, User currentUser) {
        Crop crop = cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new RuntimeException("Crop not found"));

        BigDecimal totalExpenses = expenseRepository.sumAmountByCropId(cropId);
        BigDecimal totalRevenue = harvestRepository.sumRevenueByCropId(cropId);

        return new ProfitLossResponse(
                crop.getId(),
                crop.getName(),
                totalExpenses,
                totalRevenue
        );
    }
}