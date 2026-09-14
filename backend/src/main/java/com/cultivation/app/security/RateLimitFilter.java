package com.cultivation.app.security;

import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Per-IP rate limiting for the unauthenticated auth endpoints.
 *
 * Without this, /auth/send-code and /auth/forgot-password can be driven in a
 * loop against arbitrary third-party addresses: a mail bomb sent from this
 * project's domain, which burns the daily SMTP quota and gets the sender
 * flagged as spam. The per-email cooldown in VerificationService does not help,
 * because an attacker simply rotates the address. /auth/login is included so a
 * known account cannot be guessed at indefinitely.
 *
 * Counters are in memory, which suits the single-instance deployment this runs
 * on. Behind multiple instances this would need shared state.
 */
@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RateLimitFilter.class);

    /** Endpoints that send mail or check credentials: the expensive ones. */
    private static final Map<String, Integer> STRICT_PATHS = Map.of(
        "/api/auth/send-code", 5,
        "/api/auth/forgot-password", 5,
        "/api/auth/login", 10,
        "/api/auth/verify-code", 10,
        "/api/auth/reset-password", 10,
        "/api/auth/register", 5);

    private static final Duration WINDOW = Duration.ofMinutes(1);
    /** Stops the map growing without bound under a distributed flood. */
    private static final int MAX_TRACKED_CLIENTS = 20_000;

    private final Map<String, Counter> counters = new ConcurrentHashMap<>();
    private final boolean enabled;

    public RateLimitFilter(@Value("${app.rate-limit.enabled:true}") boolean enabled) {
        this.enabled = enabled;
    }

    private static final class Counter {
        private final AtomicInteger hits = new AtomicInteger();
        private volatile Instant windowStart = Instant.now();

        /** True when this request is still inside the allowance. */
        boolean allow(int limit) {
            Instant now = Instant.now();
            if (Duration.between(windowStart, now).compareTo(WINDOW) >= 0) {
                windowStart = now;
                hits.set(0);
            }
            return hits.incrementAndGet() <= limit;
        }

        boolean isStale(Instant now) {
            return Duration.between(windowStart, now).compareTo(WINDOW.multipliedBy(5)) > 0;
        }
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        Integer limit = enabled ? STRICT_PATHS.get(request.getRequestURI()) : null;
        if (limit == null) {
            chain.doFilter(request, response);
            return;
        }

        String key = clientIp(request) + "|" + request.getRequestURI();

        if (counters.size() > MAX_TRACKED_CLIENTS) {
            Instant now = Instant.now();
            counters.entrySet().removeIf(e -> e.getValue().isStale(now));
        }

        if (!counters.computeIfAbsent(key, k -> new Counter()).allow(limit)) {
            log.warn("Rate limit hit for {} on {}", clientIp(request), request.getRequestURI());
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.setHeader("Retry-After", String.valueOf(WINDOW.toSeconds()));
            response.getWriter().write(
                "{\"status\":429,\"error\":\"Too Many Requests\","
                + "\"message\":\"Too many attempts. Please wait a minute and try again.\","
                + "\"path\":\"" + request.getRequestURI() + "\"}");
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Behind nginx every request appears to come from the proxy, so the
     * forwarded client address is preferred where present.
     */
    private static String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        String realIp = request.getHeader("X-Real-IP");
        return realIp != null && !realIp.isBlank() ? realIp : request.getRemoteAddr();
    }
}
