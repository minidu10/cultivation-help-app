package com.cultivation.app.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;

import com.cultivation.app.support.IntegrationTest;

class AuthFlowIntegrationTest extends IntegrationTest {

    @Test
    void signupReturnsAWorkingTokenPair() throws Exception {
        Session session = register();

        assertThat(session.accessToken()).isNotBlank();
        assertThat(session.refreshToken()).isNotBlank();

        getAs(session, "/api/users/me")
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value(session.email()))
            .andExpect(jsonPath("$.hasPassword").value(true))
            .andExpect(jsonPath("$.authProvider").value("LOCAL"));
    }

    @Test
    void loginResponseTellsTheClientWhenTheAccessTokenExpires() throws Exception {
        Session session = register();

        perform(post("/api/auth/login"), Map.of("email", session.email(), "password", PASSWORD), null)
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.expiresIn").value(1800));
    }

    @Test
    void registeringWithoutAConfirmedCodeIsRefused() throws Exception {
        perform(post("/api/auth/register"), Map.of(
                "fullName", "Skipper",
                "email", uniqueEmail(),
                "password", PASSWORD), null)
            .andExpect(status().isForbidden());
    }

    @Test
    void wrongPasswordIs401WithTheSameMessageAsAnUnknownEmail() throws Exception {
        Session session = register();

        String wrongPassword = perform(post("/api/auth/login"),
                Map.of("email", session.email(), "password", "Wr0ng!Pass"), null)
            .andExpect(status().isUnauthorized())
            .andReturn().getResponse().getContentAsString();
        String unknownEmail = perform(post("/api/auth/login"),
                Map.of("email", uniqueEmail(), "password", "Wr0ng!Pass"), null)
            .andExpect(status().isUnauthorized())
            .andReturn().getResponse().getContentAsString();

        assertThat(messageOf(wrongPassword)).isEqualTo(messageOf(unknownEmail));
    }

    @Test
    void loginWithMissingFieldsIs400NotAServerError() throws Exception {
        perform(post("/api/auth/login"), Map.of("email", "someone@example.com"), null)
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fieldErrors.password").exists());
    }

    // ---------------------------------------------------- 401 vs 403

    @Test
    void missingTokenIs401SoClientsKnowToRefresh() throws Exception {
        mockMvc.perform(get("/api/crops"))
            .andExpect(status().isUnauthorized())
            .andExpect(header().string(HttpHeaders.WWW_AUTHENTICATE, "Bearer"));
    }

    @Test
    void garbageTokenIs401() throws Exception {
        mockMvc.perform(get("/api/crops").header(HttpHeaders.AUTHORIZATION, "Bearer not-a-jwt"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void businessRuleRefusalStays403() throws Exception {
        Session session = register();
        long cropId = createCrop(session, Map.of(
            "name", "Paddy", "plantingDate", "2026-05-01", "aiInsightsEnabled", false));

        getAs(session, "/api/crops/" + cropId + "/insights")
            .andExpect(status().isForbidden());
    }

    // ------------------------------------------------- refresh tokens

    @Test
    void refreshIssuesANewPairAndSpendsTheOldToken() throws Exception {
        Session first = register();

        Session second = refresh(first.refreshToken());

        assertThat(second.refreshToken()).isNotEqualTo(first.refreshToken());
        getAs(second, "/api/users/me").andExpect(status().isOk());
    }

    @Test
    void replayingASpentRefreshTokenRevokesTheWholeFamily() throws Exception {
        Session original = register();
        Session rotated = refresh(original.refreshToken());

        // Someone presents the token that was already exchanged: a copy exists.
        refreshExpecting(original.refreshToken(), 401);

        // The legitimate successor dies with it, so the thief's chain is cut too.
        refreshExpecting(rotated.refreshToken(), 401);
    }

    @Test
    void anUnknownRefreshTokenIs401() throws Exception {
        refreshExpecting("this-token-was-never-issued", 401);
    }

    @Test
    void logoutRevokesTheRefreshToken() throws Exception {
        Session session = register();

        perform(post("/api/auth/logout"), Map.of("refreshToken", session.refreshToken()), null)
            .andExpect(status().isNoContent());

        refreshExpecting(session.refreshToken(), 401);
    }

    @Test
    void logoutIsIdempotent() throws Exception {
        perform(post("/api/auth/logout"), Map.of("refreshToken", "already-gone"), null)
            .andExpect(status().isNoContent());
        mockMvc.perform(post("/api/auth/logout"))
            .andExpect(status().isNoContent());
    }

    // ----------------------------------------------- password changes

    @Test
    void passwordResetSignsOutEverySession() throws Exception {
        Session session = register();
        // JWT issue times have one-second precision and the filter allows a
        // second of slack, so the reset must land clearly after the login.
        Thread.sleep(2_100);

        perform(post("/api/auth/forgot-password"), Map.of("email", session.email()), null)
            .andExpect(status().isOk());
        String code = lastPasswordResetCode(session.email());
        perform(post("/api/auth/reset-password"), Map.of(
                "email", session.email(), "code", code, "newPassword", "N3w!Password"), null)
            .andExpect(status().isOk());

        getAs(session, "/api/users/me").andExpect(status().isUnauthorized());
        refreshExpecting(session.refreshToken(), 401);
        login(session.email(), "N3w!Password");
    }

    @Test
    void changePasswordNeedsTheCurrentPassword() throws Exception {
        Session session = register();

        postAs(session, "/api/users/me/password",
               Map.of("currentPassword", "Wr0ng!Pass", "newPassword", "N3w!Password"))
            .andExpect(status().isForbidden());
    }

    @Test
    void changePasswordEnforcesThePolicy() throws Exception {
        Session session = register();

        postAs(session, "/api/users/me/password",
               Map.of("currentPassword", PASSWORD, "newPassword", "weak"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void changePasswordKeepsThisSessionButEndsTheOthers() throws Exception {
        Session phone = register();
        Session laptop = login(phone.email(), PASSWORD);

        String body = postAs(phone, "/api/users/me/password",
                             Map.of("currentPassword", PASSWORD, "newPassword", "N3w!Password"))
            .andExpect(status().isOk())
            .andReturn().getResponse().getContentAsString();
        Session renewed = session(body);

        getAs(renewed, "/api/users/me").andExpect(status().isOk());
        refreshExpecting(laptop.refreshToken(), 401);
        login(phone.email(), "N3w!Password");
    }

    // ----------------------------------------------------------- helpers

    private Session refresh(String refreshToken) throws Exception {
        String body = perform(post("/api/auth/refresh"), Map.of("refreshToken", refreshToken), null)
            .andExpect(status().isOk())
            .andReturn().getResponse().getContentAsString();
        return session(body);
    }

    private void refreshExpecting(String refreshToken, int expectedStatus) throws Exception {
        perform(post("/api/auth/refresh"), Map.of("refreshToken", refreshToken), null)
            .andExpect(status().is(expectedStatus));
    }

    private static String messageOf(String errorJson) {
        return com.jayway.jsonpath.JsonPath.read(errorJson, "$.message");
    }
}
