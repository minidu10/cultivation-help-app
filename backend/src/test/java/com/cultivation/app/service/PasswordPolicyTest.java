package com.cultivation.app.service;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import com.cultivation.app.exception.ApiException;

class PasswordPolicyTest {

    @ParameterizedTest
    @ValueSource(strings = { "Str0ng!Pass", "Aa1!aaaa", "ගොවි-Farm9" })
    void acceptsPasswordsMeetingEveryRule(String password) {
        assertThatCode(() -> PasswordPolicy.validate(password)).doesNotThrowAnyException();
    }

    @ParameterizedTest
    @ValueSource(strings = {
        "Sh0rt!",         // too short
        "nouppercase1!",  // no capital
        "NOLOWERCASE1!",  // no lowercase
        "NoDigitsHere!",  // no number
        "NoSymbols123",   // no special character
        "   "             // blank
    })
    void rejectsPasswordsMissingARule(String password) {
        assertThatThrownBy(() -> PasswordPolicy.validate(password)).isInstanceOf(ApiException.class);
    }

    @Test
    void listsEveryMissingRuleAtOnce() {
        assertThatThrownBy(() -> PasswordPolicy.validate("abc"))
            .hasMessageContaining("at least 8 characters")
            .hasMessageContaining("an uppercase letter")
            .hasMessageContaining("a number")
            .hasMessageContaining("a special character");
    }
}
