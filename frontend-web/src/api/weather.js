import api from './axios'

export const getCurrentWeather = (lat, lon) =>
  api.get('/weather/current', { params: { lat, lon } })

export const getCurrentWeatherByLocation = (location) =>
  api.get('/weather/current/by-location', { params: { location } })

export const getWeatherForecast = (lat, lon, count = 5) =>
  api.get('/weather/forecast', { params: { lat, lon, count } })

export const getWeatherForecastByLocation = (location, count = 5) =>
  api.get('/weather/forecast/by-location', { params: { location, count } })

// Five days, one row each. The 3-hourly forecast above only reaches a day ahead.
export const getDailyForecast = (lat, lon) =>
  api.get('/weather/daily', { params: { lat, lon } })

export const getDailyForecastByLocation = (location) =>
  api.get('/weather/daily/by-location', { params: { location } })

// Planned tasks the forecast puts at risk, with a better time where there is one.
export const getWeatherAlerts = () => api.get('/alerts')
