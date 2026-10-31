package com.cultivation.app.account;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.simple.JdbcClient;

import com.cultivation.app.support.IntegrationTest;

class AccountDeletionIntegrationTest extends IntegrationTest {

    /**
     * Every table in the schema. AccountDeletionService deletes rows from the
     * user-owned ones explicitly, so a new table must be added there as well
     * as here. This assertion is the reminder.
     */
    private static final Set<String> KNOWN_TABLES = Set.of(
        "users", "crops", "expenses", "harvests", "reminders", "reminder_notifications",
        "crop_insights", "email_verifications", "refresh_tokens", "flyway_schema_history",
        "crop_diagnoses", "crop_diagnosis_thumbnails", "device_tokens");

    @Autowired
    private JdbcClient jdbc;

    @Test
    void deletionNeedsProofOfOwnership() throws Exception {
        Session session = register();

        deleteAs(session, "/api/users/me").andExpect(status().isBadRequest());
        deleteAs(session, "/api/users/me", Map.of("password", "Wr0ng!Pass")).andExpect(status().isForbidden());

        getAs(session, "/api/users/me").andExpect(status().isOk());
    }

    @Test
    void deletionErasesEveryRecordAndOnlyThatUsersRecords() throws Exception {
        Session leaving = register();
        Session staying = register();
        seed(leaving);
        long keptCrop = seed(staying);
        long leavingId = userId(leaving.email());

        deleteAs(leaving, "/api/users/me", Map.of("password", PASSWORD)).andExpect(status().isNoContent());

        assertThat(count("SELECT COUNT(*) FROM users WHERE id = ?", leavingId)).isZero();
        assertThat(count("SELECT COUNT(*) FROM crops WHERE user_id = ?", leavingId)).isZero();
        assertThat(count("SELECT COUNT(*) FROM refresh_tokens WHERE user_id = ?", leavingId)).isZero();
        assertThat(count("SELECT COUNT(*) FROM email_verifications WHERE email = ?", leaving.email())).isZero();
        assertThat(count("SELECT COUNT(*) FROM expenses e LEFT JOIN crops c ON c.id = e.crop_id WHERE c.id IS NULL"))
            .as("orphaned expenses").isZero();
        assertThat(count("SELECT COUNT(*) FROM harvests h LEFT JOIN crops c ON c.id = h.crop_id WHERE c.id IS NULL"))
            .as("orphaned harvests").isZero();
        assertThat(count("SELECT COUNT(*) FROM reminders r LEFT JOIN crops c ON c.id = r.crop_id WHERE c.id IS NULL"))
            .as("orphaned reminders").isZero();

        // The other farmer is untouched.
        getAs(staying, "/api/crops/" + keptCrop).andExpect(status().isOk());
        assertThat(list(getAs(staying, "/api/crops/" + keptCrop + "/expenses"))).hasSize(1);
    }

    @Test
    void aDeletedUsersTokensStopWorking() throws Exception {
        Session session = register();

        deleteAs(session, "/api/users/me", Map.of("password", PASSWORD)).andExpect(status().isNoContent());

        getAs(session, "/api/crops").andExpect(status().isUnauthorized());
        perform(post("/api/auth/refresh"), Map.of("refreshToken", session.refreshToken()), null)
            .andExpect(status().isUnauthorized());
    }

    @Test
    void theEmailCanSignUpAgainAfterDeletion() throws Exception {
        Session first = register();
        deleteAs(first, "/api/users/me", Map.of("password", PASSWORD)).andExpect(status().isNoContent());

        Session again = register(first.email());

        assertThat(list(getAs(again, "/api/crops"))).isEmpty();
    }

    @Test
    void everyTableIsAccountedForByAccountDeletion() {
        List<String> tables = jdbc.sql(
                "SELECT table_name FROM information_schema.tables "
              + "WHERE table_schema = 'public' AND table_type = 'BASE TABLE'")
            .query(String.class)
            .list();

        assertThat(tables)
            .as("A table was added. If it holds user data, delete it in AccountDeletionService, "
              + "then add it to KNOWN_TABLES.")
            .containsExactlyInAnyOrderElementsOf(KNOWN_TABLES);
    }

    /** A crop with an expense, a harvest and a reminder; returns the crop id. */
    private long seed(Session session) throws Exception {
        long crop = createCrop(session, "Paddy");
        addExpense(session, crop, "500.00");
        addHarvest(session, crop, "10", "100.00");
        addReminder(session, crop, "2026-07-01T07:00:00");
        return crop;
    }

    private long userId(String email) {
        return jdbc.sql("SELECT id FROM users WHERE email = ?").param(email).query(Long.class).single();
    }

    private long count(String sql, Object... params) {
        JdbcClient.StatementSpec spec = jdbc.sql(sql);
        for (Object param : params) {
            spec = spec.param(param);
        }
        return spec.query(Long.class).single();
    }
}
