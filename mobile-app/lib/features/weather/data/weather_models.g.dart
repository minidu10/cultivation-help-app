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

_Forecast _$ForecastFromJson(Map<String, dynamic> json) => _Forecast(
  location: json['location'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ForecastItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ForecastToJson(_Forecast instance) => <String, dynamic>{
  'location': instance.location,
  'items': instance.items,
};

_ForecastItem _$ForecastItemFromJson(Map<String, dynamic> json) =>
    _ForecastItem(
      dateTime: json['dateTime'] as String?,
      temperatureC: (json['temperatureC'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      rainChancePercent: (json['rainChancePercent'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$ForecastItemToJson(_ForecastItem instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime,
      'temperatureC': instance.temperatureC,
      'humidity': instance.humidity,
      'rainChancePercent': instance.rainChancePercent,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
    };
