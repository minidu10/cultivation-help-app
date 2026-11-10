package com.cultivation.app.security;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;

import org.junit.jupiter.api.Test;

class RateLimiterTest {

    @Test
    void allowsUpToTheLimitThenRefuses() {
        RateLimiter limiter = new RateLimiter(true);

        for (int i = 0; i < 3; i++) {
            assertThat(limiter.tryAcquire("k", 3, Duration.ofMinutes(1))).isTrue();
        }
        assertThat(limiter.tryAcquire("k", 3, Duration.ofMinutes(1))).isFalse();
    }

    @Test
    void keysAreIndependent() {
        RateLimiter limiter = new RateLimiter(true);

        assertThat(limiter.tryAcquire("a", 1, Duration.ofMinutes(1))).isTrue();
        assertThat(limiter.tryAcquire("a", 1, Duration.ofMinutes(1))).isFalse();
        assertThat(limiter.tryAcquire("b", 1, Duration.ofMinutes(1))).isTrue();
    }

    /** A per-minute and a per-day allowance on the same key must not share a counter. */
    @Test
    void windowsOfDifferentLengthsAreCountedSeparately() {
        RateLimiter limiter = new RateLimiter(true);

        assertThat(limiter.tryAcquire("user", 1, Duration.ofMinutes(1))).isTrue();
        assertThat(limiter.tryAcquire("user", 5, Duration.ofDays(1))).isTrue();
        assertThat(limiter.tryAcquire("user", 1, Duration.ofMinutes(1))).isFalse();
    }

    @Test
    void theWindowResetsOnceItHasPassed() throws InterruptedException {
        RateLimiter limiter = new RateLimiter(true);
        Duration window = Duration.ofMillis(50);

        assertThat(limiter.tryAcquire("k", 1, window)).isTrue();
        assertThat(limiter.tryAcquire("k", 1, window)).isFalse();
        Thread.sleep(80);
        assertThat(limiter.tryAcquire("k", 1, window)).isTrue();
    }

    @Test
    void disabledLimiterAllowsEverything() {
        RateLimiter limiter = new RateLimiter(false);

        for (int i = 0; i < 100; i++) {
            assertThat(limiter.tryAcquire("k", 1, Duration.ofMinutes(1))).isTrue();
        }
    }
}
