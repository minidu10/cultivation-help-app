package com.cultivation.app.security;

import java.io.IOException;
import java.time.OffsetDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Answers 401 for a missing, expired or revoked token.
 *
 * Spring Security's default here is 403, which is also what this API returns
 * for business rules such as "AI insights are turned off for this crop". A
 * client cannot tell those apart, so it either logs people out over a rule or
 * shows a rule error when the session has simply expired. With a distinct 401
 * the web and mobile clients know exactly when to refresh the token and retry.
 */
@Component
public class RestAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setHeader("WWW-Authenticate", "Bearer");
        response.getWriter().write(
            "{\"timestamp\":\"" + OffsetDateTime.now() + "\","
            + "\"status\":401,\"error\":\"Unauthorized\","
            + "\"message\":\"Your session has expired. Please sign in again.\","
            + "\"path\":\"" + jsonEscape(request.getRequestURI()) + "\"}");
    }

    private static String jsonEscape(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
