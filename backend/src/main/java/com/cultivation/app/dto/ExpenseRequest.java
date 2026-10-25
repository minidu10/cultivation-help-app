package com.cultivation.app.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

import com.cultivation.app.entity.Expense;

import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public class ExpenseRequest {

    @NotNull(groups = OnCreate.class, message = "Category is required")
    private Expense.ExpenseCategory category;

    @NotBlank(groups = OnCreate.class, message = "Description is required")
    @Size(max = 200, message = "Description must be at most 200 characters")
    private String description;

    // Matches NUMERIC(12,2): anything wider would fail at the database.
    @NotNull(groups = OnCreate.class, message = "Amount is required")
    @Positive(message = "Amount must be greater than zero")
    @Digits(integer = 10, fraction = 2, message = "Amount can have at most 2 decimal places")
    private BigDecimal amount;

    @NotNull(groups = OnCreate.class, message = "Expense date is required")
    private LocalDate expenseDate;

    @Size(max = 500, message = "Notes must be at most 500 characters")
    private String notes;

    /**
     * Set by the phone for writes queued offline. Sending the same one twice
     * returns the first record instead of creating a duplicate.
     */
    private UUID clientRef;

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

    public UUID getClientRef() { return clientRef; }
    public void setClientRef(UUID clientRef) { this.clientRef = clientRef; }
}
