// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentWeather _$CurrentWeatherFromJson(Map<String, dynamic> json) =>
    _CurrentWeather(
      location: json['location'] as String?,
      description: json['description'] as String?,
      temperatureC: (json['temperatureC'] as num?)?.toDouble(),
      feelsLikeC: (json['feelsLikeC'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      rainMm: (json['rainMm'] as num?)?.toDouble(),
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$CurrentWeatherToJson(_CurrentWeather instance) =>
    <String, dynamic>{
      'location': instance.location,
      'description': instance.description,
      'temperatureC': instance.temperatureC,
      'feelsLikeC': instance.feelsLikeC,
      'humidity': instance.humidity,
      'windSpeed': instance.windSpeed,
      'rainMm': instance.rainMm,
      'iconUrl': instance.iconUrl,
    };

_DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) =>
    _DailyForecast(
      location: json['location'] as String?,
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => ForecastDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DailyForecastToJson(_DailyForecast instance) =>
    <String, dynamic>{'location': instance.location, 'days': instance.days};

_ForecastDay _$ForecastDayFromJson(Map<String, dynamic> json) => _ForecastDay(
  date: const DateOnlyConverter().fromJson(json['date'] as String),
  minTempC: (json['minTempC'] as num?)?.toDouble() ?? 0,
  maxTempC: (json['maxTempC'] as num?)?.toDouble() ?? 0,
  rainMm: (json['rainMm'] as num?)?.toDouble() ?? 0,
  rainChancePercent: (json['rainChancePercent'] as num?)?.toInt() ?? 0,
  maxWindSpeed: (json['maxWindSpeed'] as num?)?.toDouble() ?? 0,
  description: json['description'] as String?,
  iconUrl: json['iconUrl'] as String?,
);

Map<String, dynamic> _$ForecastDayToJson(_ForecastDay instance) =>
    <String, dynamic>{
      'date': const DateOnlyConverter().toJson(instance.date),
      'minTempC': instance.minTempC,
      'maxTempC': instance.maxTempC,
      'rainMm': instance.rainMm,
      'rainChancePercent': instance.rainChancePercent,
      'maxWindSpeed': instance.maxWindSpeed,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
    };
