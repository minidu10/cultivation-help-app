package com.cultivation.app;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.test.context.TestPropertySource;

import com.cultivation.app.support.IntegrationTest;

@TestPropertySource(properties = {
    "springdoc.api-docs.enabled=true",
    "springdoc.swagger-ui.enabled=true"
})
class PublicEndpointsIntegrationTest extends IntegrationTest {

    @Test
    void healthIsPublic() throws Exception {
        mockMvc.perform(get("/api/health")).andExpect(status().isOk());
    }

    /** springdoc 2.x targeted Boot 3; this proves the 3.x line generates docs on Boot 4. */
    @Test
    void openApiDocsListTheNewEndpoints() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.paths['/api/dashboard/summary']").exists())
            .andExpect(jsonPath("$.paths['/api/auth/refresh']").exists());
    }

    /** No API key is configured in tests: the integration is off, the server is not broken. */
    @Test
    void weatherWithoutAKeyIs503Not500() throws Exception {
        mockMvc.perform(get("/api/weather/current").param("lat", "7.94").param("lon", "81.0"))
            .andExpect(status().isServiceUnavailable());
    }

    @Test
    void weatherWithoutCoordinatesIs400() throws Exception {
        mockMvc.perform(get("/api/weather/current"))
            .andExpect(status().isBadRequest());
    }
}
