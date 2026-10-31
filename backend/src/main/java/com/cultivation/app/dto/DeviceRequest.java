package com.cultivation.app.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class DeviceRequest {

    @NotBlank(message = "Token is required")
    @Size(max = 512, message = "Token is too long")
    private String token;

    @NotBlank(message = "Platform is required")
    @Pattern(regexp = "(?i)android|ios", message = "Platform must be android or ios")
    private String platform;

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getPlatform() { return platform; }
    public void setPlatform(String platform) { this.platform = platform; }
}
