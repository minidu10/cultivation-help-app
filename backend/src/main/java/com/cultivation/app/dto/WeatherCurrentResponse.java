package com.cultivation.app.dto;

public class WeatherCurrentResponse {

    private String location;
    private String description;
    private Double temperatureC;
    private Double feelsLikeC;
    private Integer humidity;
    private Double windSpeed;
    private Double rainMm;
    private String iconCode;
    private String iconUrl;

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Double getTemperatureC() { return temperatureC; }
    public void setTemperatureC(Double temperatureC) { this.temperatureC = temperatureC; }

    public Double getFeelsLikeC() { return feelsLikeC; }
    public void setFeelsLikeC(Double feelsLikeC) { this.feelsLikeC = feelsLikeC; }

    public Integer getHumidity() { return humidity; }
    public void setHumidity(Integer humidity) { this.humidity = humidity; }

    public Double getWindSpeed() { return windSpeed; }
    public void setWindSpeed(Double windSpeed) { this.windSpeed = windSpeed; }

    public Double getRainMm() { return rainMm; }
    public void setRainMm(Double rainMm) { this.rainMm = rainMm; }

    public String getIconCode() { return iconCode; }
    public void setIconCode(String iconCode) { this.iconCode = iconCode; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }
}
