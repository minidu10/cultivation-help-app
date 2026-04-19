import api from './axios'

export const getCurrentWeather = (lat, lon) =>
  api.get('/weather/current', { params: { lat, lon } })

export const getCurrentWeatherByLocation = (location) =>
  api.get('/weather/current/by-location', { params: { location } })

export const getWeatherForecast = (lat, lon, count = 5) =>
  api.get('/weather/forecast', { params: { lat, lon, count } })

export const getWeatherForecastByLocation = (location, count = 5) =>
  api.get('/weather/forecast/by-location', { params: { location, count } })
