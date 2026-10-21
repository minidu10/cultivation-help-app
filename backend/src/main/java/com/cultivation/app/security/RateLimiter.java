package com.cultivation.app.security;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Fixed-window counters keyed by any string: an IP and path for the public
 * endpoints, a user id for the AI calls that cost money.
 *
 * Counters are in memory, which suits the single-instance deployment this runs
 * on. Behind multiple instances this would need shared state.
 */
@Component
public class RateLimiter {

    /** Stops the map growing without bound under a distributed flood. */
    private static final int MAX_TRACKED_KEYS = 20_000;

    private final Map<String, Window> windows = new ConcurrentHashMap<>();
    private final boolean enabled;

    public RateLimiter(@Value("${app.rate-limit.enabled:true}") boolean enabled) {
        this.enabled = enabled;
    }

    /** True when this call is still inside the allowance for the key. */
    public boolean tryAcquire(String key, int limit, Duration window) {
        if (!enabled) {
            return true;
        }
        if (windows.size() > MAX_TRACKED_KEYS) {
            Instant now = Instant.now();
            windows.entrySet().removeIf(e -> e.getValue().isStale(now));
        }
        return windows.computeIfAbsent(key + "|" + window.toSeconds(), k -> new Window(window)).allow(limit);
    }

    private static final class Window {
        private final Duration length;
        private Instant start = Instant.now();
        private int hits;

        Window(Duration length) {
            this.length = length;
        }

        synchronized boolean allow(int limit) {
            Instant now = Instant.now();
            if (Duration.between(start, now).compareTo(length) >= 0) {
                start = now;
                hits = 0;
            }
            return ++hits <= limit;
        }

        synchronized boolean isStale(Instant now) {
            return Duration.between(start, now).compareTo(length.multipliedBy(2)) > 0;
        }
    }
}
