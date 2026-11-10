package com.cultivation.app.crop;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.cultivation.app.support.IntegrationTest;

/**
 * One farmer must never see or change another farmer's records.
 *
 * Every lookup answers 404 rather than 403 for someone else's data, so the API
 * does not even confirm that an id exists.
 */
class OwnershipIntegrationTest extends IntegrationTest {

    private Session owner;
    private Session intruder;
    private long cropId;
    private long expenseId;
    private long harvestId;
    private long reminderId;

    @BeforeEach
    void ownerHasRecords() throws Exception {
        owner = register();
        intruder = register();
        cropId = createCrop(owner, "Paddy BG 300");
        expenseId = addExpense(owner, cropId, "1500.00");
        harvestId = addHarvest(owner, cropId, "100", "120.00");
        reminderId = addReminder(owner, cropId, "2026-06-01T07:00:00");
    }

    @Test
    void cropListsAreSeparate() throws Exception {
        assertThat(list(getAs(intruder, "/api/crops"))).isEmpty();
        assertThat(list(getAs(owner, "/api/crops"))).hasSize(1);
    }

    @Test
    void anotherFarmersCropIsInvisible() throws Exception {
        getAs(intruder, "/api/crops/" + cropId).andExpect(status().isNotFound());
        putAs(intruder, "/api/crops/" + cropId, Map.of("name", "Mine now")).andExpect(status().isNotFound());
        deleteAs(intruder, "/api/crops/" + cropId).andExpect(status().isNotFound());
        getAs(intruder, "/api/crops/" + cropId + "/insights").andExpect(status().isNotFound());
        getAs(intruder, "/api/crops/" + cropId + "/expenses/profit-loss").andExpect(status().isNotFound());

        getAs(owner, "/api/crops/" + cropId).andExpect(status().isOk());
    }

    @Test
    void anotherFarmersExpensesAreUntouchable() throws Exception {
        String base = "/api/crops/" + cropId + "/expenses";

        getAs(intruder, base).andExpect(status().isNotFound());
        postAs(intruder, base, Map.of(
                "category", "LABOR", "description", "x", "amount", "1", "expenseDate", "2026-05-01"))
            .andExpect(status().isNotFound());
        putAs(intruder, base + "/" + expenseId, Map.of("amount", "1")).andExpect(status().isNotFound());
        deleteAs(intruder, base + "/" + expenseId).andExpect(status().isNotFound());

        assertThat(list(getAs(owner, base))).hasSize(1);
    }

    @Test
    void anotherFarmersHarvestsAreUntouchable() throws Exception {
        String base = "/api/crops/" + cropId + "/harvests";

        getAs(intruder, base).andExpect(status().isNotFound());
        putAs(intruder, base + "/" + harvestId, Map.of("quantity", "1")).andExpect(status().isNotFound());
        deleteAs(intruder, base + "/" + harvestId).andExpect(status().isNotFound());

        assertThat(list(getAs(owner, base))).hasSize(1);
    }

    @Test
    void anotherFarmersRemindersAreUntouchable() throws Exception {
        String base = "/api/crops/" + cropId + "/reminders";

        getAs(intruder, base).andExpect(status().isNotFound());
        putAs(intruder, base + "/" + reminderId, Map.of("completed", true)).andExpect(status().isNotFound());
        deleteAs(intruder, base + "/" + reminderId).andExpect(status().isNotFound());

        assertThat(list(getAs(owner, base))).hasSize(1);
    }

    /** The crop in the URL must be the record's own crop, not just any crop the caller owns. */
    @Test
    void aRecordCannotBeReachedThroughTheWrongCrop() throws Exception {
        long otherCrop = createCrop(owner, "Chilli MI-2");

        deleteAs(owner, "/api/crops/" + otherCrop + "/expenses/" + expenseId).andExpect(status().isNotFound());
        deleteAs(owner, "/api/crops/" + otherCrop + "/harvests/" + harvestId).andExpect(status().isNotFound());
        putAs(owner, "/api/crops/" + otherCrop + "/reminders/" + reminderId, Map.of("completed", true))
            .andExpect(status().isNotFound());

        assertThat(list(getAs(owner, "/api/crops/" + cropId + "/expenses"))).hasSize(1);
        assertThat(list(getAs(owner, "/api/crops/" + cropId + "/harvests"))).hasSize(1);
    }

    @Test
    void remindersForAMissingCropAre404NotAnEmptyList() throws Exception {
        getAs(owner, "/api/crops/999999999/reminders").andExpect(status().isNotFound());
    }

    @Test
    void dashboardOnlyCountsTheCallersOwnCrops() throws Exception {
        assertThat(IntegrationTest.<Integer>read(getAs(intruder, "/api/dashboard/summary"), "$.totals.totalCrops"))
            .isZero();
    }
}
