package com.cultivation.app.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.cultivation.app.entity.Harvest;

public class HarvestResponse {

    private Long id;
    private LocalDate harvestDate;
    private BigDecimal quantity;
    private Harvest.QuantityUnit unit;
    private BigDecimal pricePerUnit;
    private BigDecimal totalRevenue;
    private String buyerName;
    private String notes;
    private LocalDateTime createdAt;

    public static HarvestResponse fromEntity(Harvest harvest) {
        HarvestResponse response = new HarvestResponse();
        response.setId(harvest.getId());
        response.setHarvestDate(harvest.getHarvestDate());
        response.setQuantity(harvest.getQuantity());
        response.setUnit(harvest.getUnit());
        response.setPricePerUnit(harvest.getPricePerUnit());
        response.setTotalRevenue(harvest.getTotalRevenue());
        response.setBuyerName(harvest.getBuyerName());
        response.setNotes(harvest.getNotes());
        response.setCreatedAt(harvest.getCreatedAt());
        return response;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public LocalDate getHarvestDate() { return harvestDate; }
    public void setHarvestDate(LocalDate harvestDate) { this.harvestDate = harvestDate; }

    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }

    public Harvest.QuantityUnit getUnit() { return unit; }
    public void setUnit(Harvest.QuantityUnit unit) { this.unit = unit; }

    public BigDecimal getPricePerUnit() { return pricePerUnit; }
    public void setPricePerUnit(BigDecimal pricePerUnit) { this.pricePerUnit = pricePerUnit; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}