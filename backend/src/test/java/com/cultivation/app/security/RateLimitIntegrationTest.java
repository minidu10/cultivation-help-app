package com.cultivation.app.security;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.ResultActions;

import com.cultivation.app.support.IntegrationTest;

/**
 * Each test uses its own client address, because the counters live in a
 * singleton shared by every test in this context.
 */
@TestPropertySource(properties = {
    "app.rate-limit.enabled=true",
    "app.rate-limit.ai-per-minute=2"
})
class RateLimitIntegrationTest extends IntegrationTest {

    private static final String BAD_LOGIN = "{\"email\":\"nobody@example.com\",\"password\":\"Wr0ng!Pass\"}";

    @Test
    void loginIsCappedPerClient() throws Exception {
        String ip = freshIp();
        for (int i = 0; i < 10; i++) {
            badLogin(ip, null).andExpect(status().isUnauthorized());
        }
        badLogin(ip, null)
            .andExpect(status().isTooManyRequests())
            .andExpect(header().string("Retry-After", "60"));
    }

    /** The old limiter keyed on the first X-Forwarded-For value, which the client controls. */
    @Test
    void spoofingXForwardedForDoesNotResetTheLimit() throws Exception {
        String ip = freshIp();
        for (int i = 0; i < 10; i++) {
            badLogin(ip, "203.0.113." + i).andExpect(status().isUnauthorized());
        }
        badLogin(ip, "198.51.100.77").andExpect(status().isTooManyRequests());
    }

    @Test
    void differentClientsHaveSeparateAllowances() throws Exception {
        String first = freshIp();
        for (int i = 0; i < 11; i++) {
            badLogin(first, null);
        }
        badLogin(freshIp(), null).andExpect(status().isUnauthorized());
    }

    @Test
    void aiQuestionsAreCappedPerFarmer() throws Exception {
        Session session = register();
        Map<String, String> question = Map.of("question", "When should I apply urea to paddy?");

        // No AI service runs in tests, so allowed calls fail upstream with 503;
        // what matters is that the third one never gets that far.
        postAs(session, "/api/ai/ask", question).andExpect(status().isServiceUnavailable());
        postAs(session, "/api/ai/ask", question).andExpect(status().isServiceUnavailable());
        postAs(session, "/api/ai/ask", question).andExpect(status().isTooManyRequests());
    }

    private ResultActions badLogin(String realIp, String forwardedFor) throws Exception {
        var request = post("/api/auth/login")
            .contentType(MediaType.APPLICATION_JSON)
            .content(BAD_LOGIN)
            .header("X-Real-IP", realIp);
        if (forwardedFor != null) {
            request.header("X-Forwarded-For", forwardedFor);
        }
        return mockMvc.perform(request);
    }

    /** A private-range address unique to the calling test. */
    private static String freshIp() {
        int n = Math.abs(UUID.randomUUID().hashCode());
        return "10." + (n >> 16 & 0xff) + "." + (n >> 8 & 0xff) + "." + (n & 0xff);
    }
}
