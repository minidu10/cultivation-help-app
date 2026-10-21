package com.cultivation.app.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.dto.DashboardSummaryResponse;
import com.cultivation.app.dto.DashboardSummaryResponse.CropSummary;
import com.cultivation.app.dto.DashboardSummaryResponse.Totals;
import com.cultivation.app.dto.ReminderResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.ExpenseRepository;
import com.cultivation.app.repository.HarvestRepository;
import com.cultivation.app.repository.ReminderRepository;

@Service
public class DashboardService {

    /** How far ahead "upcoming" reaches; matches the forecast horizon. */
    private static final int UPCOMING_DAYS = 7;

    private final CropRepository cropRepository;
    private final ExpenseRepository expenseRepository;
    private final HarvestRepository harvestRepository;
    private final ReminderRepository reminderRepository;
    private final ReminderService reminderService;

    public DashboardService(CropRepository cropRepository,
                            ExpenseRepository expenseRepository,
                            HarvestRepository harvestRepository,
                            ReminderRepository reminderRepository,
                            ReminderService reminderService) {
        this.cropRepository = cropRepository;
        this.expenseRepository = expenseRepository;
        this.harvestRepository = harvestRepository;
        this.reminderRepository = reminderRepository;
        this.reminderService = reminderService;
    }

    /**
     * Four queries in total, however many crops the farmer has: crops, two
     * grouped sums, and reminders. The per-crop approach was 1 + N.
     */
    @Transactional(readOnly = true)
    public DashboardSummaryResponse summary(User currentUser) {
        List<Crop> crops = cropRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId());
        Map<Long, BigDecimal> expensesByCrop = toMap(expenseRepository.sumAmountPerCropForUser(currentUser.getId()));
        Map<Long, BigDecimal> revenueByCrop = toMap(harvestRepository.sumRevenuePerCropForUser(currentUser.getId()));

        BigDecimal totalExpenses = BigDecimal.ZERO;
        BigDecimal totalRevenue = BigDecimal.ZERO;
        int active = 0;

        List<CropSummary> summaries = new ArrayList<>(crops.size());
        for (Crop crop : crops) {
            BigDecimal expenses = expensesByCrop.getOrDefault(crop.getId(), BigDecimal.ZERO);
            BigDecimal revenue = revenueByCrop.getOrDefault(crop.getId(), BigDecimal.ZERO);
            BigDecimal net = revenue.subtract(expenses);

            totalExpenses = totalExpenses.add(expenses);
            totalRevenue = totalRevenue.add(revenue);
            if (isActive(crop)) {
                active++;
            }

            summaries.add(new CropSummary(
                crop.getId(), crop.getName(), crop.getVariety(), crop.getStatus(),
                crop.getFieldLocation(), crop.getPlantingDate(), crop.getExpectedHarvestDate(),
                crop.getAiInsightsEnabled(), expenses, revenue, net,
                net.compareTo(BigDecimal.ZERO) >= 0 ? "PROFIT" : "LOSS"));
        }

        LocalDateTime now = LocalDateTime.now();
        List<ReminderResponse> upcoming = reminderRepository
            .findActiveForUserBetween(currentUser.getId(), now, now.plusDays(UPCOMING_DAYS))
            .stream()
            .map(ReminderResponse::new)
            .toList();

        Totals totals = new Totals(totalRevenue, totalExpenses, totalRevenue.subtract(totalExpenses),
                                   active, crops.size());
        return new DashboardSummaryResponse(totals, summaries,
                                            reminderService.getDueReminders(currentUser), upcoming);
    }

    /** Same rule the web dashboard used: still in the ground, not written off. */
    private static boolean isActive(Crop crop) {
        return crop.getStatus() != Crop.CropStatus.HARVESTED && crop.getStatus() != Crop.CropStatus.FAILED;
    }

    private static Map<Long, BigDecimal> toMap(List<Object[]> rows) {
        Map<Long, BigDecimal> map = new HashMap<>();
        for (Object[] row : rows) {
            // The SUM's Java type depends on the dialect; going through the
            // string keeps the exact decimal value whatever it is.
            map.put(((Number) row[0]).longValue(), new BigDecimal(row[1].toString()));
        }
        return map;
    }
}
