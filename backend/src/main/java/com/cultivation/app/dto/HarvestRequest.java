package com.cultivation.app.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

import com.cultivation.app.entity.Harvest;

import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public class HarvestRequest {

    @NotNull(groups = OnCreate.class, message = "Harvest date is required")
    private LocalDate harvestDate;

    // Matches NUMERIC(12,3).
    @NotNull(groups = OnCreate.class, message = "Quantity is required")
    @Positive(message = "Quantity must be greater than zero")
    @Digits(integer = 9, fraction = 3, message = "Quantity can have at most 3 decimal places")
    private BigDecimal quantity;

    @NotNull(groups = OnCreate.class, message = "Unit is required")
    private Harvest.QuantityUnit unit;

    // Zero is allowed: produce given away or kept for the household.
    @NotNull(groups = OnCreate.class, message = "Price per unit is required")
    @PositiveOrZero(message = "Price cannot be negative")
    @Digits(integer = 10, fraction = 2, message = "Price can have at most 2 decimal places")
    private BigDecimal pricePerUnit;

    @Size(max = 200, message = "Buyer name must be at most 200 characters")
    private String buyerName;

    @Size(max = 500, message = "Notes must be at most 500 characters")
    private String notes;

    /**
     * Set by the phone for writes queued offline. Sending the same one twice
     * returns the first record instead of creating a duplicate.
     */
    private UUID clientRef;

    public LocalDate getHarvestDate() { return harvestDate; }
    public void setHarvestDate(LocalDate harvestDate) { this.harvestDate = harvestDate; }

    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }

    public Harvest.QuantityUnit getUnit() { return unit; }
    public void setUnit(Harvest.QuantityUnit unit) { this.unit = unit; }

    public BigDecimal getPricePerUnit() { return pricePerUnit; }
    public void setPricePerUnit(BigDecimal pricePerUnit) { this.pricePerUnit = pricePerUnit; }

    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public UUID getClientRef() { return clientRef; }
    public void setClientRef(UUID clientRef) { this.clientRef = clientRef; }
}
