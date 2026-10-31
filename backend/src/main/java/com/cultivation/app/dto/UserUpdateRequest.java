package com.cultivation.app.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class UserUpdateRequest {

    @Size(max = 100, message = "Name must be at most 100 characters")
    private String fullName;

    @Size(max = 20, message = "Phone must be at most 20 characters")
    private String phone;

    @Size(max = 100, message = "City must be at most 100 characters")
    private String city;

    @Pattern(regexp = "(?i)LIGHT|DARK", message = "Theme must be LIGHT or DARK")
    private String themePreference;

    private Boolean desktopMode;
    private Boolean reminderEmailsEnabled;

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getThemePreference() { return themePreference; }
    public void setThemePreference(String themePreference) { this.themePreference = themePreference; }

    public Boolean getDesktopMode() { return desktopMode; }
    public void setDesktopMode(Boolean desktopMode) { this.desktopMode = desktopMode; }
    public Boolean getReminderEmailsEnabled() { return reminderEmailsEnabled; }
    public void setReminderEmailsEnabled(Boolean reminderEmailsEnabled) { this.reminderEmailsEnabled = reminderEmailsEnabled; }
}
