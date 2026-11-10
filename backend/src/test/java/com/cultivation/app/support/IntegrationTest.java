package com.cultivation.app.support;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;

import com.cultivation.app.service.MailService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

/**
 * Base for tests that boot the whole application against real Postgres.
 *
 * One container is started for the entire test run and shared by every
 * Spring context, so a test class that needs different properties costs a
 * context refresh, not another database. Tests never clean up: each one signs
 * up fresh users with random emails, so their data cannot collide.
 */
@SpringBootTest
@AutoConfigureMockMvc
public abstract class IntegrationTest {

    protected static final String PASSWORD = "Str0ng!Pass";

    private static final PostgreSQLContainer POSTGRES =
        new PostgreSQLContainer(DockerImageName.parse("postgres:16-alpine"));

    static {
        POSTGRES.start();
    }

    @DynamicPropertySource
    static void datasource(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
    }

    private static final ObjectMapper JSON = new ObjectMapper();

    @Autowired
    protected MockMvc mockMvc;

    /** Nothing is ever mailed; tests read verification codes off the mock instead. */
    @MockitoBean
    protected MailService mailService;

    /** A signed-up user as a client sees them. */
    protected record Session(String accessToken, String refreshToken, String email) {
        public String bearer() {
            return "Bearer " + accessToken;
        }
    }

    // ------------------------------------------------------------ accounts

    protected static String uniqueEmail() {
        return "farmer-" + UUID.randomUUID().toString().substring(0, 8) + "@example.com";
    }

    /** The full three-step signup: send code, confirm it, create the account. */
    protected Session register() throws Exception {
        return register(uniqueEmail());
    }

    protected Session register(String email) throws Exception {
        perform(post("/api/auth/send-code"), Map.of("email", email), null)
            .andExpect(status().isOk());

        perform(post("/api/auth/verify-code"),
                Map.of("email", email, "code", lastVerificationCode(email)), null)
            .andExpect(status().isOk());

        String body = perform(post("/api/auth/register"), Map.of(
                "fullName", "Test Farmer",
                "email", email,
                "password", PASSWORD,
                "city", "Polonnaruwa"), null)
            .andExpect(status().isOk())
            .andReturn().getResponse().getContentAsString();
        return session(body);
    }

    protected Session login(String email, String password) throws Exception {
        String body = perform(post("/api/auth/login"), Map.of("email", email, "password", password), null)
            .andExpect(status().isOk())
            .andReturn().getResponse().getContentAsString();
        return session(body);
    }

    protected String lastVerificationCode(String email) {
        ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
        verify(mailService, atLeastOnce()).sendVerificationCode(eq(email), code.capture());
        return code.getValue();
    }

    protected String lastPasswordResetCode(String email) {
        ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
        verify(mailService, atLeastOnce()).sendPasswordResetCode(eq(email), code.capture());
        return code.getValue();
    }

    protected static Session session(String authResponseJson) {
        return new Session(
            JsonPath.read(authResponseJson, "$.token"),
            JsonPath.read(authResponseJson, "$.refreshToken"),
            JsonPath.read(authResponseJson, "$.email"));
    }

    // --------------------------------------------------------------- data

    protected long createCrop(Session session, String name) throws Exception {
        return createCrop(session, Map.of("name", name, "plantingDate", "2026-05-01"));
    }

    protected long createCrop(Session session, Map<String, ?> body) throws Exception {
        return idOf(perform(post("/api/crops"), body, session).andExpect(status().isOk()));
    }

    protected long addExpense(Session session, long cropId, String amount) throws Exception {
        return idOf(perform(post("/api/crops/" + cropId + "/expenses"), Map.of(
                "category", "FERTILIZER",
                "description", "Urea",
                "amount", amount,
                "expenseDate", "2026-05-10"), session)
            .andExpect(status().isOk()));
    }

    protected long addHarvest(Session session, long cropId, String quantity, String price) throws Exception {
        return idOf(perform(post("/api/crops/" + cropId + "/harvests"), Map.of(
                "harvestDate", "2026-08-20",
                "quantity", quantity,
                "unit", "KG",
                "pricePerUnit", price), session)
            .andExpect(status().isOk()));
    }

    protected long addReminder(Session session, long cropId, String reminderAt) throws Exception {
        return idOf(perform(post("/api/crops/" + cropId + "/reminders"), Map.of(
                "title", "Apply fertilizer",
                "type", "FERTILIZER",
                "reminderAt", reminderAt), session)
            .andExpect(status().isOk()));
    }

    // ------------------------------------------------------------ requests

    protected ResultActions getAs(Session session, String path) throws Exception {
        return perform(get(path), null, session);
    }

    protected ResultActions postAs(Session session, String path, Object body) throws Exception {
        return perform(post(path), body, session);
    }

    protected ResultActions putAs(Session session, String path, Object body) throws Exception {
        return perform(put(path), body, session);
    }

    protected ResultActions deleteAs(Session session, String path) throws Exception {
        return perform(delete(path), null, session);
    }

    protected ResultActions deleteAs(Session session, String path, Object body) throws Exception {
        return perform(delete(path), body, session);
    }

    protected ResultActions perform(MockHttpServletRequestBuilder request, Object body, Session session)
            throws Exception {
        if (body != null) {
            request.contentType(MediaType.APPLICATION_JSON).content(
                body instanceof String raw ? raw : JSON.writeValueAsString(body));
        }
        if (session != null) {
            request.header(HttpHeaders.AUTHORIZATION, session.bearer());
        }
        return mockMvc.perform(request);
    }

    protected static long idOf(ResultActions result) throws Exception {
        Number id = JsonPath.read(result.andReturn().getResponse().getContentAsString(), "$.id");
        return id.longValue();
    }

    protected static <T> T read(ResultActions result, String path) throws Exception {
        return JsonPath.read(result.andReturn().getResponse().getContentAsString(), path);
    }

    protected static List<Map<String, Object>> list(ResultActions result) throws Exception {
        return JsonPath.read(result.andReturn().getResponse().getContentAsString(), "$");
    }
}
