package com.cultivation.app.dto;

public class UserUpdateRequest {

    private String fullName;
    private String phone;
    private String city;
    private String themePreference;
    private Boolean desktopMode;

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
}
