package com.cultivation.app.service;

import java.time.Duration;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.security.RateLimiter;

/**
 * Fronts the AI service for the chat advisor.
 *
 * The browser used to call the AI service directly through an nginx passthrough,
 * which made it an unauthenticated, unmetered LLM endpoint billed to this
 * project's API key - anyone who found the URL could spend it. Routing through
 * here means every request carries a JWT and is attributable to a farmer, and
 * the AI service no longer needs to be reachable from outside the compose network.
 */
@Service
public class AiAdvisorService {

    private static final Logger log = LoggerFactory.getLogger(AiAdvisorService.class);

    /** Bounds what one request can push into the model's context. */
    private static final int MAX_QUESTION_CHARS = 1000;
    private static final int MAX_CONTEXT_CHARS = 2000;

    private final RestTemplate restTemplate;
    private final String aiServiceUrl;
    private final RateLimiter rateLimiter;
    private final int perMinute;
    private final int perDay;

    public AiAdvisorService(@Qualifier("aiRestTemplate") RestTemplate restTemplate,
                            @Value("${app.ai.service-url:http://ai-service:8000}") String aiServiceUrl,
                            RateLimiter rateLimiter,
                            @Value("${app.rate-limit.ai-per-minute:10}") int perMinute,
                            @Value("${app.rate-limit.ai-per-day:150}") int perDay) {
        this.restTemplate = restTemplate;
        this.aiServiceUrl = aiServiceUrl;
        this.rateLimiter = rateLimiter;
        this.perMinute = perMinute;
        this.perDay = perDay;
    }

    /**
     * Shared by every feature that calls the model on a farmer's behalf, so
     * the allowance is per person rather than per feature.
     */
    public void checkQuota(User user) {
        String key = "ai:" + user.getId();
        if (!rateLimiter.tryAcquire(key, perMinute, Duration.ofMinutes(1))) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                "You are asking very quickly. Wait a minute and try again.");
        }
        if (!rateLimiter.tryAcquire(key, perDay, Duration.ofDays(1))) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                "You have reached today's AI limit. It resets tomorrow.");
        }
    }

    /**
     * Health of the downstream AI service, for the advisor page's status badge.
     * Failures are reported rather than thrown: the page needs to render
     * "Offline" rather than break.
     */
    public Map<String, Object> health() {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.getForObject(
                aiServiceUrl + "/ai/health", Map.class);
            return response == null ? downMap() : response;
        } catch (RestClientException ex) {
            log.debug("AI health check failed: {}", ex.getMessage());
            return downMap();
        }
    }

    private static Map<String, Object> downMap() {
        return Map.of("status", "DOWN", "service", "AI Advisor", "configured", false);
    }

    public String ask(String question, String cropContext, User currentUser) {
        if (question == null || question.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Question cannot be empty");
        }
        if (question.length() > MAX_QUESTION_CHARS) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                "Question is too long (max " + MAX_QUESTION_CHARS + " characters)");
        }

        checkQuota(currentUser);

        String context = cropContext == null ? "" : cropContext;
        if (context.length() > MAX_CONTEXT_CHARS) {
            context = context.substring(0, MAX_CONTEXT_CHARS);
        }

        Map<String, Object> body = Map.of(
            "question", question.trim(),
            "crop_context", context);

        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.postForObject(
                aiServiceUrl + "/ai/ask", body, Map.class);

            String answer = response == null ? null : (String) response.get("answer");
            if (answer == null || answer.isBlank()) {
                throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "AI returned no answer");
            }
            log.debug("AI question answered for user {}", currentUser.getId());
            return answer;
        } catch (RestClientException ex) {
            log.warn("AI request failed for user {}: {}", currentUser.getId(), ex.getMessage());
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                "The AI advisor is unavailable. Try again shortly.");
        }
    }
}
