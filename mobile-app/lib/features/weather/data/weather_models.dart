import 'package:freezed_annotation/freezed_annotation.dart';

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

@freezed
abstract class Forecast with _$Forecast {
  const factory Forecast({
    String? location,
    @Default([]) List<ForecastItem> items,
  }) = _Forecast;

  factory Forecast.fromJson(Map<String, dynamic> json) => _$ForecastFromJson(json);
}

@freezed
abstract class ForecastItem with _$ForecastItem {
  const factory ForecastItem({
    /// OpenWeather's "2026-05-10 09:00:00", in UTC.
    String? dateTime,
    double? temperatureC,
    int? humidity,
    @Default(0) int rainChancePercent,
    String? description,
    String? iconUrl,
  }) = _ForecastItem;

  factory ForecastItem.fromJson(Map<String, dynamic> json) => _$ForecastItemFromJson(json);
}
