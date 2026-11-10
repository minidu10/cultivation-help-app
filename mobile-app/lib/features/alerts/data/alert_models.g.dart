// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherAlert _$WeatherAlertFromJson(Map<String, dynamic> json) =>
    _WeatherAlert(
      type: $enumDecode(
        _$AlertTypeEnumMap,
        json['type'],
        unknownValue: AlertType.unknown,
      ),
      severity:
          $enumDecodeNullable(
            _$AlertSeverityEnumMap,
            json['severity'],
            unknownValue: AlertSeverity.medium,
          ) ??
          AlertSeverity.medium,
      cropId: (json['cropId'] as num?)?.toInt(),
      cropName: json['cropName'] as String? ?? '',
      reminderId: (json['reminderId'] as num?)?.toInt(),
      reminderTitle: json['reminderTitle'] as String?,
      reminderAt: const NullableLocalDateTimeConverter().fromJson(
        json['reminderAt'] as String?,
      ),
      location: json['location'] as String? ?? '',
      date: const DateOnlyConverter().fromJson(json['date'] as String),
      rainChancePercent: (json['rainChancePercent'] as num?)?.toInt() ?? 0,
      rainMm: (json['rainMm'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      maxTempC: (json['maxTempC'] as num?)?.toDouble() ?? 0,
      suggestedAt: const NullableLocalDateTimeConverter().fromJson(
        json['suggestedAt'] as String?,
      ),
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$WeatherAlertToJson(_WeatherAlert instance) =>
    <String, dynamic>{
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'cropId': instance.cropId,
      'cropName': instance.cropName,
      'reminderId': instance.reminderId,
      'reminderTitle': instance.reminderTitle,
      'reminderAt': const NullableLocalDateTimeConverter().toJson(
        instance.reminderAt,
      ),
      'location': instance.location,
      'date': const DateOnlyConverter().toJson(instance.date),
      'rainChancePercent': instance.rainChancePercent,
      'rainMm': instance.rainMm,
      'windSpeed': instance.windSpeed,
      'maxTempC': instance.maxTempC,
      'suggestedAt': const NullableLocalDateTimeConverter().toJson(
        instance.suggestedAt,
      ),
      'message': instance.message,
    };

const _$AlertTypeEnumMap = {
  AlertType.rainWashoff: 'RAIN_WASHOFF',
  AlertType.sprayWind: 'SPRAY_WIND',
  AlertType.irrigationRain: 'IRRIGATION_RAIN',
  AlertType.harvestRain: 'HARVEST_RAIN',
  AlertType.heatStress: 'HEAT_STRESS',
  AlertType.unknown: 'UNKNOWN',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.high: 'HIGH',
  AlertSeverity.medium: 'MEDIUM',
};
