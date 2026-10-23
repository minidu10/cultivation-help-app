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
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofSeconds(5));
        factory.setReadTimeout(Duration.ofSeconds(10));
        return new RestTemplate(factory);
    }
}
