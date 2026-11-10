import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'weather_models.freezed.dart';
part 'weather_models.g.dart';

@freezed
abstract class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    String? location,
    String? description,
    double? temperatureC,
    double? feelsLikeC,
    int? humidity,
    double? windSpeed,
    double? rainMm,
    String? iconUrl,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);
}

/// GET /api/weather/daily: five days, one row each.
@freezed
abstract class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    String? location,
    @Default([]) List<ForecastDay> days,
  }) = _DailyForecast;

  factory DailyForecast.fromJson(Map<String, dynamic> json) => _$DailyForecastFromJson(json);
}

@freezed
abstract class ForecastDay with _$ForecastDay {
  const factory ForecastDay({
    @DateOnlyConverter() required DateTime date,
    @Default(0) double minTempC,
    @Default(0) double maxTempC,
    @Default(0) double rainMm,
    @Default(0) int rainChancePercent,
    @Default(0) double maxWindSpeed,
    String? description,
    String? iconUrl,
  }) = _ForecastDay;

  factory ForecastDay.fromJson(Map<String, dynamic> json) => _$ForecastDayFromJson(json);
}
