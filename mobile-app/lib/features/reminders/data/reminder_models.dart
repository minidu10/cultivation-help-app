import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'reminder_models.freezed.dart';
part 'reminder_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReminderType {
  fertilizer,
  irrigation,
  pestControl,
  harvest,
  other;

  String get wire => _$ReminderTypeEnumMap[this]!;
}

@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required int id,
    required int cropId,
    required String title,
    @JsonKey(unknownEnumValue: ReminderType.other) @Default(ReminderType.other) ReminderType type,
    @LocalDateTimeConverter() required DateTime reminderAt,
    @Default(true) bool enabled,
    @Default(false) bool aiRecommended,
    @Default(false) bool completed,
    String? note,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);
}
