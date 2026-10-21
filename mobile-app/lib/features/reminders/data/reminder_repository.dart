import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/json/converters.dart';
import '../../../core/providers.dart';
import 'reminder_models.dart';

final reminderRepositoryProvider =
    Provider<ReminderRepository>((ref) => ReminderRepository(ref.watch(dioProvider)));

final remindersProvider = FutureProvider.autoDispose.family<List<Reminder>, int>(
  (ref, cropId) => ref.watch(reminderRepositoryProvider).list(cropId),
);

class ReminderInput {
  const ReminderInput({this.title, this.type, this.reminderAt, this.completed, this.enabled, this.note});

  final String? title;
  final ReminderType? type;
  final DateTime? reminderAt;
  final bool? completed;
  final bool? enabled;
  final String? note;

  Map<String, Object?> toJson() => compact({
        'title': title?.trim(),
        'type': type?.wire,
        'reminderAt': reminderAt == null ? null : formatLocalDateTime(reminderAt!),
        'completed': completed,
        'enabled': enabled,
        'note': note?.trim(),
      });
}

class ReminderRepository {
  ReminderRepository(this._dio);

  final Dio _dio;

  Future<List<Reminder>> list(int cropId) => guard(() async {
        final res = await _dio.get<List<dynamic>>('/crops/$cropId/reminders');
        return res.data!.map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
      });

  Future<Reminder> add(int cropId, ReminderInput input) => guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/crops/$cropId/reminders', data: input.toJson());
        return Reminder.fromJson(res.data!);
      });

  Future<Reminder> update(int cropId, int reminderId, ReminderInput input) => guard(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          '/crops/$cropId/reminders/$reminderId',
          data: input.toJson(),
        );
        return Reminder.fromJson(res.data!);
      });

  Future<void> delete(int cropId, int reminderId) =>
      guard(() => _dio.delete<void>('/crops/$cropId/reminders/$reminderId'));
}
