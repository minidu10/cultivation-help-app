package com.cultivation.app.dto;

import java.math.BigDecimal;

public class ProfitLossResponse {

    private Long cropId;
    private String cropName;
    private BigDecimal totalExpenses;
    private BigDecimal totalRevenue;
    private BigDecimal netProfit;
    private String result; // "PROFIT" or "LOSS"

    public ProfitLossResponse(Long cropId, String cropName,
                               BigDecimal totalExpenses, BigDecimal totalRevenue) {
        this.cropId = cropId;
        this.cropName = cropName;
        this.totalExpenses = totalExpenses;
        this.totalRevenue = totalRevenue;
        this.netProfit = totalRevenue.subtract(totalExpenses);
        this.result = this.netProfit.compareTo(BigDecimal.ZERO) >= 0 ? "PROFIT" : "LOSS";
    }

    public Long getCropId() { return cropId; }
    public String getCropName() { return cropName; }
    public BigDecimal getTotalExpenses() { return totalExpenses; }
    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public BigDecimal getNetProfit() { return netProfit; }
    public String getResult() { return result; }
}