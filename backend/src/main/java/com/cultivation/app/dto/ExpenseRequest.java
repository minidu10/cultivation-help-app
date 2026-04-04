package com.cultivation.app.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.cultivation.app.entity.Expense;

public class ExpenseRequest {

    private Expense.ExpenseCategory category;
    private String description;
    private BigDecimal amount;
    private LocalDate expenseDate;
    private String notes;

    public Expense.ExpenseCategory getCategory() { return category; }
    public void setCategory(Expense.ExpenseCategory category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public LocalDate getExpenseDate() { return expenseDate; }
    public void setExpenseDate(LocalDate expenseDate) { this.expenseDate = expenseDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}