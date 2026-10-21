// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: (json['id'] as num).toInt(),
  category: $enumDecode(
    _$ExpenseCategoryEnumMap,
    json['category'],
    unknownValue: ExpenseCategory.miscellaneous,
  ),
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  expenseDate: const DateOnlyConverter().fromJson(
    json['expenseDate'] as String,
  ),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
  'description': instance.description,
  'amount': instance.amount,
  'expenseDate': const DateOnlyConverter().toJson(instance.expenseDate),
  'notes': instance.notes,
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.fertilizer: 'FERTILIZER',
  ExpenseCategory.labor: 'LABOR',
  ExpenseCategory.transport: 'TRANSPORT',
  ExpenseCategory.equipment: 'EQUIPMENT',
  ExpenseCategory.seeds: 'SEEDS',
  ExpenseCategory.pesticides: 'PESTICIDES',
  ExpenseCategory.irrigation: 'IRRIGATION',
  ExpenseCategory.miscellaneous: 'MISCELLANEOUS',
};
