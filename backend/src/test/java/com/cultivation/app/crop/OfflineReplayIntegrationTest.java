package com.cultivation.app.crop;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.junit.jupiter.api.Test;

import com.cultivation.app.support.IntegrationTest;

/**
 * A phone that saved an expense offline sends it when the signal returns.
 * If the reply is lost on the way back, it sends it again. However many
 * copies arrive, and in whatever order, there must be one row.
 */
class OfflineReplayIntegrationTest extends IntegrationTest {

    private static Map<String, Object> expense(UUID clientRef) {
        Map<String, Object> body = new HashMap<>(Map.of(
            "category", "FERTILIZER", "description", "Urea 50kg", "amount", "4500", "expenseDate", "2026-05-10"));
        if (clientRef != null) {
            body.put("clientRef", clientRef.toString());
        }
        return body;
    }

    private static Map<String, Object> harvest(UUID clientRef) {
        return Map.of("harvestDate", "2026-08-20", "quantity", "120", "unit", "KG", "pricePerUnit", "95",
                      "clientRef", clientRef.toString());
    }

    @Test
    void aReplayedExpenseReturnsTheOriginalInsteadOfADuplicate() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        UUID ref = UUID.randomUUID();

        long first = idOf(postAs(session, "/api/crops/" + crop + "/expenses", expense(ref)).andExpect(status().isOk()));
        long again = idOf(postAs(session, "/api/crops/" + crop + "/expenses", expense(ref))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.clientRef").value(ref.toString())));

        assertThat(again).isEqualTo(first);
        assertThat(list(getAs(session, "/api/crops/" + crop + "/expenses"))).hasSize(1);
    }

    @Test
    void aReplayedHarvestIsAlsoKeptOnce() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        UUID ref = UUID.randomUUID();

        postAs(session, "/api/crops/" + crop + "/harvests", harvest(ref)).andExpect(status().isOk());
        postAs(session, "/api/crops/" + crop + "/harvests", harvest(ref)).andExpect(status().isOk());

        assertThat(list(getAs(session, "/api/crops/" + crop + "/harvests"))).hasSize(1);
    }

    /** The database index, not a check-then-insert, is what makes this safe. */
    @Test
    void copiesArrivingAtTheSameMomentStillMakeOneRow() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        UUID ref = UUID.randomUUID();

        ExecutorService pool = Executors.newFixedThreadPool(8);
        try {
            List<Callable<Long>> sends = new ArrayList<>();
            for (int i = 0; i < 8; i++) {
                sends.add(() -> idOf(postAs(session, "/api/crops/" + crop + "/expenses", expense(ref))
                    .andExpect(status().isOk())));
            }
            List<Long> ids = new ArrayList<>();
            for (Future<Long> f : pool.invokeAll(sends)) {
                ids.add(f.get());
            }
            assertThat(ids).containsOnly(ids.get(0));
        } finally {
            pool.shutdownNow();
        }

        assertThat(list(getAs(session, "/api/crops/" + crop + "/expenses"))).hasSize(1);
    }

    @Test
    void writesWithoutAReferenceAreNeverMerged() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");

        postAs(session, "/api/crops/" + crop + "/expenses", expense(null)).andExpect(status().isOk());
        postAs(session, "/api/crops/" + crop + "/expenses", expense(null)).andExpect(status().isOk());

        assertThat(list(getAs(session, "/api/crops/" + crop + "/expenses"))).hasSize(2);
    }

    @Test
    void theSameReferenceOnAnotherCropIsADifferentRecord() throws Exception {
        Session session = register();
        long paddy = createCrop(session, "Paddy");
        long chilli = createCrop(session, "Chilli");
        UUID ref = UUID.randomUUID();

        long a = idOf(postAs(session, "/api/crops/" + paddy + "/expenses", expense(ref)));
        long b = idOf(postAs(session, "/api/crops/" + chilli + "/expenses", expense(ref)));

        assertThat(a).isNotEqualTo(b);
    }

    @Test
    void aReplayCannotReachAnotherFarmersRecord() throws Exception {
        Session owner = register();
        long crop = createCrop(owner, "Paddy");
        UUID ref = UUID.randomUUID();
        postAs(owner, "/api/crops/" + crop + "/expenses", expense(ref)).andExpect(status().isOk());

        postAs(register(), "/api/crops/" + crop + "/expenses", expense(ref)).andExpect(status().isNotFound());
    }

    @Test
    void aMalformedReferenceIs400() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        Map<String, Object> body = expense(null);
        body.put("clientRef", "not-a-uuid");

        postAs(session, "/api/crops/" + crop + "/expenses", body).andExpect(status().isBadRequest());
    }
}
