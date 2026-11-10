package com.cultivation.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import org.springframework.beans.factory.annotation.Value;

import com.cultivation.app.security.JwtFilter;
import com.cultivation.app.security.RestAuthenticationEntryPoint;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtFilter jwtFilter;
    private final RestAuthenticationEntryPoint authenticationEntryPoint;
    private final boolean swaggerEnabled;

    public SecurityConfig(JwtFilter jwtFilter,
                          RestAuthenticationEntryPoint authenticationEntryPoint,
                          @Value("${springdoc.swagger-ui.enabled:false}") boolean swaggerEnabled) {
        this.jwtFilter = jwtFilter;
        this.authenticationEntryPoint = authenticationEntryPoint;
        this.swaggerEnabled = swaggerEnabled;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        if (swaggerEnabled) {
            http.authorizeHttpRequests(auth -> auth
                .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**")
                .permitAll());
        }

        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .exceptionHandling(ex -> ex.authenticationEntryPoint(authenticationEntryPoint))
            .authorizeHttpRequests(auth -> auth
                // Spring forwards errors here; locking it turns every 404 or
                // 405 into a misleading 401.
                .requestMatchers("/error").permitAll()
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/api/weather/**").permitAll()
                .requestMatchers("/api/auth/register").permitAll()
                .requestMatchers("/api/auth/login").permitAll()
                .requestMatchers("/api/auth/send-code").permitAll()
                .requestMatchers("/api/auth/verify-code").permitAll()
                .requestMatchers("/api/auth/forgot-password").permitAll()
                .requestMatchers("/api/auth/reset-password").permitAll()
                .requestMatchers("/api/auth/config").permitAll()
                .requestMatchers("/api/auth/google").permitAll()
                // The refresh token is the credential here, not a JWT: these
                // are exactly the calls made once the access token has expired.
                .requestMatchers("/api/auth/refresh").permitAll()
                .requestMatchers("/api/auth/logout").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}