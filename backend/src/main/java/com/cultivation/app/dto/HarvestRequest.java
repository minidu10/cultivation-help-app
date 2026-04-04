package com.cultivation.app.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.cultivation.app.entity.Harvest;

public class HarvestRequest {

    private LocalDate harvestDate;
    private BigDecimal quantity;
    private Harvest.QuantityUnit unit;
    private BigDecimal pricePerUnit;
    private String buyerName;
    private String notes;

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
}