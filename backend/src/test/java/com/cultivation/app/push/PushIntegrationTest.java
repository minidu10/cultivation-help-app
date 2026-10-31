package com.cultivation.app.push;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.client.ExpectedCount.manyTimes;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.mock.http.client.MockClientHttpRequest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.service.FcmAccessTokens;
import com.cultivation.app.service.ReminderNotificationJob;
import com.cultivation.app.support.IntegrationTest;
import com.jayway.jsonpath.JsonPath;

@TestPropertySource(properties = {
    "app.reminders.email-enabled=true",
    "app.reminders.lead-days=2,1"
})
class PushIntegrationTest extends IntegrationTest {

    private static final String FCM = "https://fcm.googleapis.com/v1/projects/test-project/messages:send";

    @MockitoBean
    private FcmAccessTokens fcmTokens;

    @Autowired
    @Qualifier("fcmRestTemplate")
    private RestTemplate fcm;

    @Autowired
    private JdbcClient jdbc;

    @Autowired
    private ReminderNotificationJob digestJob;

    private MockRestServiceServer server;
    private final List<String> pushes = new ArrayList<>();

    @BeforeEach
    void firebaseConfigured() {
        when(fcmTokens.isConfigured()).thenReturn(true);
        when(fcmTokens.projectId()).thenReturn("test-project");
        when(fcmTokens.accessToken()).thenReturn(Optional.of("fake-access-token"));
        pushes.clear();
        server = MockRestServiceServer.bindTo(fcm).ignoreExpectOrder(true).build();
    }

    private void fcmAccepts() {
        server.expect(manyTimes(), requestTo(FCM)).andRespond(request -> {
            pushes.add(((MockClientHttpRequest) request).getBodyAsString());
            return withSuccess("{\"name\":\"projects/test-project/messages/1\"}", MediaType.APPLICATION_JSON)
                .createResponse(request);
        });
    }

    private static String phone() {
        return "fcm-token-" + UUID.randomUUID();
    }

    private void registerPhone(Session session, String token) throws Exception {
        postAs(session, "/api/devices", Map.of("token", token, "platform", "android"))
            .andExpect(status().isNoContent());
    }

    private Long ownerOf(String token) {
        return jdbc.sql("SELECT user_id FROM device_tokens WHERE token = ?").param(token)
            .query(Long.class).optional().orElse(null);
    }

    private Long idOf(Session session) {
        return jdbc.sql("SELECT id FROM users WHERE email = ?").param(session.email()).query(Long.class).single();
    }

    // -------------------------------------------------------- registration

    @Test
    void aPhoneRegistersOnceHoweverOftenItAsks() throws Exception {
        Session session = register();
        String token = phone();

        registerPhone(session, token);
        registerPhone(session, token);

        assertThat(jdbc.sql("SELECT COUNT(*) FROM device_tokens WHERE token = ?").param(token)
            .query(Long.class).single()).isEqualTo(1);
        assertThat(ownerOf(token)).isEqualTo(idOf(session));
    }

    /** Someone else signs in on the same phone: the notifications are theirs now. */
    @Test
    void aTokenMovesToWhoeverIsSignedInOnThatPhone() throws Exception {
        Session first = register();
        Session second = register();
        String token = phone();

        registerPhone(first, token);
        registerPhone(second, token);

        assertThat(ownerOf(token)).isEqualTo(idOf(second));
    }

    @Test
    void signingOutStopsNotifications() throws Exception {
        Session session = register();
        String token = phone();
        registerPhone(session, token);

        deleteAs(session, "/api/devices/" + token).andExpect(status().isNoContent());

        assertThat(ownerOf(token)).isNull();
    }

    @Test
    void nobodyCanUnregisterSomeoneElsesPhone() throws Exception {
        Session owner = register();
        String token = phone();
        registerPhone(owner, token);

        deleteAs(register(), "/api/devices/" + token).andExpect(status().isNoContent());

        assertThat(ownerOf(token)).isEqualTo(idOf(owner));
    }

    @Test
    void onlyAndroidAndIosAreAccepted() throws Exception {
        postAs(register(), "/api/devices", Map.of("token", phone(), "platform", "windows"))
            .andExpect(status().isBadRequest());
    }

    // ------------------------------------------------------------- sending

    @Test
    void theTestNotificationReachesFcmWithTheServiceAccountToken() throws Exception {
        server.expect(manyTimes(), requestTo(FCM))
            .andExpect(header("Authorization", "Bearer fake-access-token"))
            .andRespond(request -> {
                pushes.add(((MockClientHttpRequest) request).getBodyAsString());
                return withSuccess("{}", MediaType.APPLICATION_JSON).createResponse(request);
            });
        Session session = register();
        String token = phone();
        registerPhone(session, token);

        mockMvc.perform(post("/api/devices/test").header("Authorization", session.bearer()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.sent").value(1));

        String body = pushes.get(0);
        assertThat((String) JsonPath.read(body, "$.message.token")).isEqualTo(token);
        assertThat((String) JsonPath.read(body, "$.message.notification.title")).isEqualTo("AgroMaster is connected");
        assertThat((String) JsonPath.read(body, "$.message.android.notification.channel_id")).isEqualTo("reminders");
    }

    @Test
    void aTokenFcmNoLongerKnowsIsRemoved() throws Exception {
        server.expect(manyTimes(), requestTo(FCM)).andRespond(withStatus(HttpStatus.NOT_FOUND)
            .contentType(MediaType.APPLICATION_JSON)
            .body("{\"error\":{\"status\":\"NOT_FOUND\",\"details\":[{\"errorCode\":\"UNREGISTERED\"}]}}"));
        Session session = register();
        String token = phone();
        registerPhone(session, token);

        mockMvc.perform(post("/api/devices/test").header("Authorization", session.bearer()))
            .andExpect(jsonPath("$.sent").value(0));

        assertThat(ownerOf(token)).isNull();
    }

    // -------------------------------------------------------------- digest

    @Test
    void theDailyDigestReachesThePhoneEvenWithEmailsOff() throws Exception {
        fcmAccepts();
        Session session = register();
        putAs(session, "/api/users/me", Map.of("reminderEmailsEnabled", false)).andExpect(status().isOk());
        registerPhone(session, phone());
        long crop = createCrop(session, "Paddy");
        addReminder(session, crop, LocalDate.now().plusDays(1).format(DateTimeFormatter.ISO_LOCAL_DATE) + "T07:00:00");

        digestJob.sendUpcomingDigests();

        verify(mailService, never()).sendReminderDigest(eq(session.email()), anyString(), anyString(), anyInt());
        String mine = pushes.stream().filter(p -> p.contains("\"cropId\":\"" + crop + "\"")).findFirst().orElseThrow();
        assertThat((String) JsonPath.read(mine, "$.message.notification.title"))
            .isEqualTo("Apply fertilizer tomorrow at 7:00 AM");
        assertThat((String) JsonPath.read(mine, "$.message.data.type")).isEqualTo("reminders");
    }

    @Test
    void aTaskIsPushedOnceNotEveryRun() throws Exception {
        fcmAccepts();
        Session session = register();
        registerPhone(session, phone());
        long crop = createCrop(session, "Chilli");
        addReminder(session, crop, LocalDate.now().plusDays(1).format(DateTimeFormatter.ISO_LOCAL_DATE) + "T07:00:00");

        digestJob.sendUpcomingDigests();
        digestJob.sendUpcomingDigests();

        assertThat(pushes.stream().filter(p -> p.contains("\"cropId\":\"" + crop + "\""))).hasSize(1);
        // Email is still on for this farmer, and it too goes out once.
        verify(mailService).sendReminderDigest(eq(session.email()), anyString(), contains("Apply fertilizer"), eq(1));
    }
}
