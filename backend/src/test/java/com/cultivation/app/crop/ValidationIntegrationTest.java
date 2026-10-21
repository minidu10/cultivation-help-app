package com.cultivation.app.crop;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.cultivation.app.support.IntegrationTest;

/**
 * Bad input is the client's mistake and must come back as a 400 naming the
 * field. Before validation was added, each of these reached the database and
 * surfaced as "Unexpected server error".
 */
class ValidationIntegrationTest extends IntegrationTest {

    private Session session;
    private long cropId;

    @BeforeEach
    void signedIn() throws Exception {
        session = register();
        cropId = createCrop(session, "Tomato Thilina");
    }

    @Test
    void cropNeedsANameAndPlantingDate() throws Exception {
        postAs(session, "/api/crops", Map.of("variety", "BG 300"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fieldErrors.name").exists())
            .andExpect(jsonPath("$.fieldErrors.plantingDate").exists());
    }

    @Test
    void harvestCannotBeExpectedBeforePlanting() throws Exception {
        postAs(session, "/api/crops", Map.of(
                "name", "Paddy", "plantingDate", "2026-05-01", "expectedHarvestDate", "2026-04-01"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("Expected harvest date cannot be before the planting date"));
    }

    @Test
    void cropUpdateIsPartialSoOnlyChangedFieldsAreNeeded() throws Exception {
        putAs(session, "/api/crops/" + cropId, Map.of("status", "GROWING"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("GROWING"))
            .andExpect(jsonPath("$.name").value("Tomato Thilina"));
    }

    @Test
    void expenseAmountMustBePositive() throws Exception {
        postAs(session, "/api/crops/" + cropId + "/expenses", Map.of(
                "category", "SEEDS", "description", "Seed", "amount", "-50", "expenseDate", "2026-05-02"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fieldErrors.amount").exists());
    }

    @Test
    void expenseAmountCannotHaveMoreDecimalsThanTheColumn() throws Exception {
        postAs(session, "/api/crops/" + cropId + "/expenses", Map.of(
                "category", "SEEDS", "description", "Seed", "amount", "10.555", "expenseDate", "2026-05-02"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void unknownEnumValueIs400() throws Exception {
        postAs(session, "/api/crops/" + cropId + "/expenses", Map.of(
                "category", "FERTILISER", "description", "Urea", "amount", "100", "expenseDate", "2026-05-02"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void malformedJsonIs400() throws Exception {
        postAs(session, "/api/crops", "{\"name\": ")
            .andExpect(status().isBadRequest());
    }

    @Test
    void nonNumericIdIs400() throws Exception {
        getAs(session, "/api/crops/abc")
            .andExpect(status().isBadRequest());
    }

    @Test
    void unknownRouteIs404NotAServerError() throws Exception {
        getAs(session, "/api/no-such-thing")
            .andExpect(status().isNotFound());
    }

    @Test
    void harvestNeedsQuantityUnitAndPrice() throws Exception {
        postAs(session, "/api/crops/" + cropId + "/harvests", Map.of("harvestDate", "2026-08-01"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fieldErrors.quantity").exists())
            .andExpect(jsonPath("$.fieldErrors.unit").exists())
            .andExpect(jsonPath("$.fieldErrors.pricePerUnit").exists());
    }

    @Test
    void reminderNeedsATitleAndTime() throws Exception {
        postAs(session, "/api/crops/" + cropId + "/reminders", Map.of("type", "IRRIGATION"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fieldErrors.title").exists())
            .andExpect(jsonPath("$.fieldErrors.reminderAt").exists());
    }

    @Test
    void themeMustBeLightOrDark() throws Exception {
        putAs(session, "/api/users/me", Map.of("themePreference", "PURPLE"))
            .andExpect(status().isBadRequest());
    }

    // ------------------------------------------------ edits keep the rest

    @Test
    void editingAnExpenseKeepsTheFieldsLeftOut() throws Exception {
        long expenseId = addExpense(session, cropId, "1000.00");

        putAs(session, "/api/crops/" + cropId + "/expenses/" + expenseId, Map.of("amount", "1250.50"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.amount").value(1250.50))
            .andExpect(jsonPath("$.description").value("Urea"))
            .andExpect(jsonPath("$.category").value("FERTILIZER"));
    }

    @Test
    void editingAHarvestRecomputesItsRevenue() throws Exception {
        long harvestId = addHarvest(session, cropId, "100", "50.00");

        putAs(session, "/api/crops/" + cropId + "/harvests/" + harvestId, Map.of("pricePerUnit", "65.00"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.totalRevenue").value(6500.0));
    }

    @Test
    void deletedExpenseIsGone() throws Exception {
        long expenseId = addExpense(session, cropId, "300.00");

        deleteAs(session, "/api/crops/" + cropId + "/expenses/" + expenseId)
            .andExpect(status().isNoContent());
        deleteAs(session, "/api/crops/" + cropId + "/expenses/" + expenseId)
            .andExpect(status().isNotFound());
    }
}
