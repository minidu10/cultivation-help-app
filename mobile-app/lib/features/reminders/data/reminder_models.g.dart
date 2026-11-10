// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reminder _$ReminderFromJson(Map<String, dynamic> json) => _Reminder(
  id: (json['id'] as num).toInt(),
  cropId: (json['cropId'] as num).toInt(),
  title: json['title'] as String,
  type:
      $enumDecodeNullable(
        _$ReminderTypeEnumMap,
        json['type'],
        unknownValue: ReminderType.other,
      ) ??
      ReminderType.other,
  reminderAt: const LocalDateTimeConverter().fromJson(
    json['reminderAt'] as String,
  ),
  enabled: json['enabled'] as bool? ?? true,
  aiRecommended: json['aiRecommended'] as bool? ?? false,
  completed: json['completed'] as bool? ?? false,
  note: json['note'] as String?,
);

Map<String, dynamic> _$ReminderToJson(_Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'cropId': instance.cropId,
  'title': instance.title,
  'type': _$ReminderTypeEnumMap[instance.type]!,
  'reminderAt': const LocalDateTimeConverter().toJson(instance.reminderAt),
  'enabled': instance.enabled,
  'aiRecommended': instance.aiRecommended,
  'completed': instance.completed,
  'note': instance.note,
};

const _$ReminderTypeEnumMap = {
  ReminderType.fertilizer: 'FERTILIZER',
  ReminderType.irrigation: 'IRRIGATION',
  ReminderType.pestControl: 'PEST_CONTROL',
  ReminderType.harvest: 'HARVEST',
  ReminderType.other: 'OTHER',
};
