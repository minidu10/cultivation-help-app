package com.cultivation.app.dto;

public class WeatherForecastItemResponse {

    private String dateTime;
    private Double temperatureC;
    private Integer humidity;
    private Integer rainChancePercent;
    private String description;
    private String iconCode;
    private String iconUrl;

    public String getDateTime() { return dateTime; }
    public void setDateTime(String dateTime) { this.dateTime = dateTime; }

    public Double getTemperatureC() { return temperatureC; }
    public void setTemperatureC(Double temperatureC) { this.temperatureC = temperatureC; }

    public Integer getHumidity() { return humidity; }
    public void setHumidity(Integer humidity) { this.humidity = humidity; }

    public Integer getRainChancePercent() { return rainChancePercent; }
    public void setRainChancePercent(Integer rainChancePercent) { this.rainChancePercent = rainChancePercent; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getIconCode() { return iconCode; }
    public void setIconCode(String iconCode) { this.iconCode = iconCode; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }
}
