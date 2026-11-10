import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'expense_models.freezed.dart';
part 'expense_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ExpenseCategory {
  fertilizer,
  labor,
  transport,
  equipment,
  seeds,
  pesticides,
  irrigation,
  miscellaneous;

  String get wire => _$ExpenseCategoryEnumMap[this]!;
}

@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required int id,
    @JsonKey(unknownEnumValue: ExpenseCategory.miscellaneous) required ExpenseCategory category,
    required String description,
    required double amount,
    @DateOnlyConverter() required DateTime expenseDate,
    String? notes,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
