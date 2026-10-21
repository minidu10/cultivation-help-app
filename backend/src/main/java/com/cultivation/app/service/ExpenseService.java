package com.cultivation.app.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.cultivation.app.dto.ExpenseRequest;
import com.cultivation.app.dto.ProfitLossResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.Expense;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
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
        Crop crop = findCrop(cropId, currentUser);

        Expense expense = new Expense();
        expense.setCrop(crop);
        expense.setCategory(request.getCategory());
        expense.setDescription(request.getDescription().trim());
        expense.setAmount(request.getAmount());
        expense.setExpenseDate(request.getExpenseDate());
        expense.setNotes(request.getNotes());

        return expenseRepository.save(expense);
    }

    public List<Expense> getExpensesForCrop(Long cropId, User currentUser) {
        findCrop(cropId, currentUser);
        return expenseRepository.findByCropIdOrderByExpenseDateDesc(cropId);
    }

    /** Partial update: a field left out of the request keeps its value. */
    public Expense updateExpense(Long cropId, Long expenseId, ExpenseRequest request, User currentUser) {
        Expense expense = findExpense(cropId, expenseId, currentUser);

        if (request.getCategory() != null) expense.setCategory(request.getCategory());
        if (request.getDescription() != null && !request.getDescription().isBlank()) {
            expense.setDescription(request.getDescription().trim());
        }
        if (request.getAmount() != null) expense.setAmount(request.getAmount());
        if (request.getExpenseDate() != null) expense.setExpenseDate(request.getExpenseDate());
        if (request.getNotes() != null) expense.setNotes(request.getNotes());

        return expenseRepository.save(expense);
    }

    public void deleteExpense(Long cropId, Long expenseId, User currentUser) {
        expenseRepository.delete(findExpense(cropId, expenseId, currentUser));
    }

    // THE KEY METHOD — Profit/Loss calculation
    public ProfitLossResponse calculateProfitLoss(Long cropId, User currentUser) {
        Crop crop = findCrop(cropId, currentUser);

        BigDecimal totalExpenses = expenseRepository.sumAmountByCropId(cropId);
        BigDecimal totalRevenue = harvestRepository.sumRevenueByCropId(cropId);

        return new ProfitLossResponse(
                crop.getId(),
                crop.getName(),
                totalExpenses,
                totalRevenue
        );
    }

    private Crop findCrop(Long cropId, User currentUser) {
        return cropRepository.findByIdAndUserId(cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));
    }

    private Expense findExpense(Long cropId, Long expenseId, User currentUser) {
        return expenseRepository.findByIdAndCropIdAndCropUserId(expenseId, cropId, currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Expense not found"));
    }
}
