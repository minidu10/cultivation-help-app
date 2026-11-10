package com.cultivation.app.security;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Per-IP rate limiting for the unauthenticated endpoints.
 *
 * Without this, /auth/send-code and /auth/forgot-password can be driven in a
 * loop against arbitrary third-party addresses: a mail bomb sent from this
 * project's domain, which burns the daily SMTP quota and gets the sender
 * flagged as spam. The per-email cooldown in VerificationService does not help,
 * because an attacker simply rotates the address. /auth/login is included so a
 * known account cannot be guessed at indefinitely. Weather is public and every
 * call spends OpenWeather quota, so it is capped too.
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
        "/api/auth/register", 5,
        "/api/auth/google", 10,
        "/api/auth/refresh", 30);

    private static final String WEATHER_PREFIX = "/api/weather/";
    private static final int WEATHER_PER_MINUTE = 60;

    private static final Duration WINDOW = Duration.ofMinutes(1);

    private final RateLimiter rateLimiter;

    public RateLimitFilter(RateLimiter rateLimiter) {
        this.rateLimiter = rateLimiter;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        String path = request.getRequestURI();
        String bucket = path;
        Integer limit = STRICT_PATHS.get(path);
        if (limit == null && path.startsWith(WEATHER_PREFIX)) {
            // One shared allowance for every weather route, not one each.
            bucket = WEATHER_PREFIX;
            limit = WEATHER_PER_MINUTE;
        }
        if (limit == null) {
            chain.doFilter(request, response);
            return;
        }

        String ip = clientIp(request);
        if (!rateLimiter.tryAcquire(ip + "|" + bucket, limit, WINDOW)) {
            log.warn("Rate limit hit for {} on {}", ip, path);
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.setHeader("Retry-After", String.valueOf(WINDOW.toSeconds()));
            response.getWriter().write(
                "{\"status\":429,\"error\":\"Too Many Requests\","
                + "\"message\":\"Too many attempts. Please wait a minute and try again.\","
                + "\"path\":\"" + path + "\"}");
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * X-Real-IP is set by nginx to the address it actually received the
     * connection from, overwriting anything the client sent. X-Forwarded-For
     * is not used: its first entry is whatever the client chose to put there,
     * so trusting it let anyone reset their own limit by changing a header.
     * In production the backend listens on loopback only, so nothing but
     * nginx can reach it to set the header.
     */
    static String clientIp(HttpServletRequest request) {
        String realIp = request.getHeader("X-Real-IP");
        return realIp != null && !realIp.isBlank() ? realIp.trim() : request.getRemoteAddr();
    }
}
