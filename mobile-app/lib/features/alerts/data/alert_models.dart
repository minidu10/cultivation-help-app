import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'alert_models.freezed.dart';
part 'alert_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AlertType { rainWashoff, sprayWind, irrigationRain, harvestRain, heatStress, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AlertSeverity { high, medium }

/// A planned task the forecast puts at risk (GET /api/alerts).
///
/// The app writes its own sentence from [type] and the figures rather than
/// showing the server's English [message], so the alert reads in the
/// farmer's language. [message] is the fallback for a type this version of
/// the app does not know yet.
@freezed
abstract class WeatherAlert with _$WeatherAlert {
  const factory WeatherAlert({
    @JsonKey(unknownEnumValue: AlertType.unknown) required AlertType type,
    @JsonKey(unknownEnumValue: AlertSeverity.medium) @Default(AlertSeverity.medium) AlertSeverity severity,
    int? cropId,
    @Default('') String cropName,
    int? reminderId,
    String? reminderTitle,
    @NullableLocalDateTimeConverter() DateTime? reminderAt,
    @Default('') String location,
    @DateOnlyConverter() required DateTime date,
    @Default(0) int rainChancePercent,
    @Default(0) double rainMm,
    @Default(0) double windSpeed,
    @Default(0) double maxTempC,
    @NullableLocalDateTimeConverter() DateTime? suggestedAt,
    @Default('') String message,
  }) = _WeatherAlert;

  const WeatherAlert._();

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => _$WeatherAlertFromJson(json);

  /// True when the alert can be fixed in one tap: a task with a better time.
  bool get canReschedule => reminderId != null && cropId != null && suggestedAt != null;
}
