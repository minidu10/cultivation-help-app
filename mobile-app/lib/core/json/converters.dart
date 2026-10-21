import 'package:json_annotation/json_annotation.dart';

/// `LocalDate` on the server: "2026-05-10", no time, no zone.
class DateOnlyConverter implements JsonConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime date) => formatDateOnly(date);
}

class NullableDateOnlyConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateOnlyConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? date) => date == null ? null : formatDateOnly(date);
}

/// `LocalDateTime` on the server: "2026-05-10T07:00:00" with no zone.
///
/// The backend stores farm-local time (Asia/Colombo) without an offset, so it
/// is parsed and sent as local time. Converting through UTC here would shift
/// a 7 AM reminder by five and a half hours.
class LocalDateTimeConverter implements JsonConverter<DateTime, String> {
  const LocalDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime value) => formatLocalDateTime(value);
}

class NullableLocalDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableLocalDateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? value) => value == null ? null : formatLocalDateTime(value);
}

String formatDateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

String formatLocalDateTime(DateTime value) =>
    '${formatDateOnly(value)}T${_two(value.hour)}:${_two(value.minute)}:${_two(value.second)}';

String _two(int n) => n.toString().padLeft(2, '0');
