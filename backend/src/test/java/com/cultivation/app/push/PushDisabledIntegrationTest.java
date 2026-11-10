package com.cultivation.app.push;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import org.junit.jupiter.api.Test;

import com.cultivation.app.support.IntegrationTest;

/** No Firebase credentials: push is off, and nothing else breaks. */
class PushDisabledIntegrationTest extends IntegrationTest {

    @Test
    void phonesCanStillRegisterSoPushWorksOnceConfigured() throws Exception {
        postAs(register(), "/api/devices", Map.of("token", "a-token", "platform", "ios"))
            .andExpect(status().isNoContent());
    }

    @Test
    void theTestNotificationExplainsThatPushIsOff() throws Exception {
        Session session = register();

        mockMvc.perform(post("/api/devices/test").header("Authorization", session.bearer()))
            .andExpect(status().isServiceUnavailable());
    }
}
