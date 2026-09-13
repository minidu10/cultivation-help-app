package com.cultivation.app.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class SendCodeRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Enter a valid email address")
    @Size(max = 100)
    private String email;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
