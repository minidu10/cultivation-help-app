package com.cultivation.app.config;

import java.time.Duration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

/**
 * HTTP clients for outside services, each with timeouts.
 *
 * A bare RestTemplate waits forever. Weather alerts are computed while the
 * farmer waits on a page, so a stalled OpenWeather must fail in seconds and
 * let the page render without them, not hold the request open indefinitely.
 */
@Configuration
public class HttpClientConfig {

    @Bean
    public RestTemplate openWeatherRestTemplate() {
        return withTimeouts(Duration.ofSeconds(5), Duration.ofSeconds(10));
    }

    /**
     * The AI service. Reasoning models and photo diagnosis can take most of a
     * minute, so the read timeout is long, but still finite: nginx gives up
     * at 120 seconds, and the backend should answer before it does.
     */
    @Bean
    public RestTemplate aiRestTemplate() {
        return withTimeouts(Duration.ofSeconds(5), Duration.ofSeconds(90));
    }

    private static RestTemplate withTimeouts(Duration connect, Duration read) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connect);
        factory.setReadTimeout(read);
        return new RestTemplate(factory);
    }
}
