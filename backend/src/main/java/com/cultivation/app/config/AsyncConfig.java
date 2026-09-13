package com.cultivation.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Enables @Async (welcome and reminder emails, so SMTP never blocks a request)
 * and @Scheduled (the reminder notification job).
 */
@Configuration
@EnableAsync
@EnableScheduling
public class AsyncConfig {
}
