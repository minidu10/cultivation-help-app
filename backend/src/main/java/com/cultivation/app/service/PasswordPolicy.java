package com.cultivation.app.service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import org.springframework.http.HttpStatus;

import com.cultivation.app.exception.ApiException;

/**
 * Server-side password rules, mirroring the checks in RegisterPage.jsx.
 *
 * These previously existed only in the frontend, which meant a direct POST to
 * /api/auth/register bypassed them entirely. Password reset needs the same
 * rules, so they live here and are applied by both paths.
 */
public final class PasswordPolicy {

    private static final int MIN_LENGTH = 8;
    private static final Pattern UPPER = Pattern.compile("[A-Z]");
    private static final Pattern LOWER = Pattern.compile("[a-z]");
    private static final Pattern DIGIT = Pattern.compile("[0-9]");
    private static final Pattern SYMBOL = Pattern.compile("[^A-Za-z0-9]");

    private PasswordPolicy() {
    }

    public static void validate(String password) {
        if (password == null || password.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Password is required");
        }

        List<String> problems = new ArrayList<>();
        if (password.length() < MIN_LENGTH)          problems.add("at least " + MIN_LENGTH + " characters");
        if (!UPPER.matcher(password).find())         problems.add("an uppercase letter");
        if (!LOWER.matcher(password).find())         problems.add("a lowercase letter");
        if (!DIGIT.matcher(password).find())         problems.add("a number");
        if (!SYMBOL.matcher(password).find())        problems.add("a special character");

        if (!problems.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                "Password must contain " + String.join(", ", problems));
        }
    }
}
