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
import com.cultivation.app.dto.ExpenseResponse;
import com.cultivation.app.dto.ProfitLossResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.ExpenseService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/crops/{cropId}/expenses")
@Tag(name = "Expenses", description = "Track cultivation costs")
public class ExpenseController {

    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @PostMapping
    @Operation(summary = "Add an expense to a crop")
    public ResponseEntity<ExpenseResponse> addExpense(
            @PathVariable Long cropId,
            @RequestBody ExpenseRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(
                ExpenseResponse.fromEntity(expenseService.addExpense(cropId, request, currentUser))
        );
    }

    @GetMapping
    @Operation(summary = "Get all expenses for a crop")
    public ResponseEntity<List<ExpenseResponse>> getExpenses(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(
                expenseService.getExpensesForCrop(cropId, currentUser)
                        .stream()
                        .map(ExpenseResponse::fromEntity)
                        .toList()
        );
    }

    @DeleteMapping("/{expenseId}")
    @Operation(summary = "Calculate profit or loss for a crop")
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