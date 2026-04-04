package com.cultivation.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.ExpenseRequest;
import com.cultivation.app.dto.ProfitLossResponse;
import com.cultivation.app.entity.Expense;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.ExpenseService;

@RestController
@RequestMapping("/api/crops/{cropId}/expenses")
public class ExpenseController {

    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @PostMapping
    public ResponseEntity<Expense> addExpense(
            @PathVariable Long cropId,
            @RequestBody ExpenseRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(expenseService.addExpense(cropId, request, currentUser));
    }

    @GetMapping
    public ResponseEntity<List<Expense>> getExpenses(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(expenseService.getExpensesForCrop(cropId, currentUser));
    }

    @DeleteMapping("/{expenseId}")
    public ResponseEntity<Void> deleteExpense(
            @PathVariable Long cropId,
            @PathVariable Long expenseId,
            @AuthenticationPrincipal User currentUser) {
        expenseService.deleteExpense(expenseId, currentUser);
        return ResponseEntity.noContent().build();
    }

    // Profit/Loss for this crop
    @GetMapping("/profit-loss")
    public ResponseEntity<ProfitLossResponse> getProfitLoss(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(expenseService.calculateProfitLoss(cropId, currentUser));
    }
}