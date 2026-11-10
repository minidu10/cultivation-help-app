package com.cultivation.app.dashboard;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.ResultActions;

import com.cultivation.app.support.IntegrationTest;

class DashboardSummaryIntegrationTest extends IntegrationTest {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    @Test
    void totalsMatchTheSumOfEveryCrop() throws Exception {
        Session session = register();

        // Profitable: 2,000 revenue against 1,500.50 of costs.
        long paddy = createCrop(session, "Paddy");
        addExpense(session, paddy, "1000.00");
        addExpense(session, paddy, "500.50");
        addHarvest(session, paddy, "100", "20.00");

        // Written off: costs, no harvest.
        long onion = createCrop(session, Map.of("name", "Big Onion", "plantingDate", "2026-05-01", "status", "FAILED"));
        addExpense(session, onion, "300.00");

        ResultActions summary = getAs(session, "/api/dashboard/summary")
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.totals.totalRevenue").value(2000.0))
            .andExpect(jsonPath("$.totals.totalExpenses").value(1800.50))
            .andExpect(jsonPath("$.totals.netProfit").value(199.50))
            .andExpect(jsonPath("$.totals.activeCrops").value(1))
            .andExpect(jsonPath("$.totals.totalCrops").value(2));

        List<Map<String, Object>> crops = read(summary, "$.crops");
        Map<String, Object> paddyRow = row(crops, paddy);
        Map<String, Object> onionRow = row(crops, onion);

        assertThat(paddyRow.get("result")).isEqualTo("PROFIT");
        assertThat(((Number) paddyRow.get("netProfit")).doubleValue()).isEqualTo(499.50);
        assertThat(onionRow.get("result")).isEqualTo("LOSS");
        assertThat(((Number) onionRow.get("netProfit")).doubleValue()).isEqualTo(-300.0);
    }

    /** The summary must agree with the per-crop endpoint it replaces. */
    @Test
    void perCropFiguresMatchTheProfitLossEndpoint() throws Exception {
        Session session = register();
        long chilli = createCrop(session, "Green Chilli");
        addExpense(session, chilli, "750.25");
        addHarvest(session, chilli, "12.5", "180.00");

        Number fromProfitLoss = read(getAs(session, "/api/crops/" + chilli + "/expenses/profit-loss"), "$.netProfit");
        Number fromSummary = read(getAs(session, "/api/dashboard/summary"), "$.crops[0].netProfit");

        assertThat(fromSummary.doubleValue()).isEqualTo(fromProfitLoss.doubleValue());
    }

    @Test
    void cropWithNoRecordsShowsZeroes() throws Exception {
        Session session = register();
        createCrop(session, "Tomato");

        getAs(session, "/api/dashboard/summary")
            .andExpect(jsonPath("$.crops[0].totalExpenses").value(0))
            .andExpect(jsonPath("$.crops[0].totalRevenue").value(0))
            .andExpect(jsonPath("$.crops[0].result").value("PROFIT"));
    }

    @Test
    void remindersAreSplitIntoDueAndUpcoming() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        LocalDateTime now = LocalDateTime.now().withNano(0);

        addReminder(session, crop, now.minusHours(3).format(ISO));   // overdue
        addReminder(session, crop, now.plusDays(2).format(ISO));     // this week
        addReminder(session, crop, now.plusDays(30).format(ISO));    // too far out

        getAs(session, "/api/dashboard/summary")
            .andExpect(jsonPath("$.dueReminders.length()").value(1))
            .andExpect(jsonPath("$.upcomingReminders.length()").value(1));
    }

    @Test
    void completedRemindersAreLeftOut() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        long reminder = addReminder(session, crop, LocalDateTime.now().plusDays(1).withNano(0).format(ISO));

        putAs(session, "/api/crops/" + crop + "/reminders/" + reminder, Map.of("completed", true))
            .andExpect(status().isOk());

        getAs(session, "/api/dashboard/summary")
            .andExpect(jsonPath("$.upcomingReminders.length()").value(0));
    }

    private static Map<String, Object> row(List<Map<String, Object>> crops, long cropId) {
        return crops.stream()
            .filter(c -> ((Number) c.get("cropId")).longValue() == cropId)
            .findFirst()
            .orElseThrow();
    }
}
