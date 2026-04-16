package com.cultivation.app.dto;

import java.util.List;

public class WeatherForecastResponse {

    private String location;
    private List<WeatherForecastItemResponse> items;

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public List<WeatherForecastItemResponse> getItems() { return items; }
    public void setItems(List<WeatherForecastItemResponse> items) { this.items = items; }
}
