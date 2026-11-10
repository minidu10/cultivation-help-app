import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/json/converters.dart';
import '../../../core/providers.dart';
import 'expense_models.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) => ExpenseRepository(ref.watch(dioProvider)));

final expensesProvider = FutureProvider.autoDispose.family<List<Expense>, int>(
  (ref, cropId) => ref.watch(expenseRepositoryProvider).list(cropId),
);

class ExpenseInput {
  const ExpenseInput({this.category, this.description, this.amount, this.expenseDate, this.notes, this.clientRef});

  final ExpenseCategory? category;
  final String? description;
  final double? amount;
  final DateTime? expenseDate;
  final String? notes;

  /// Generated on the phone for new records, so a resend is not a duplicate.
  final String? clientRef;

  Map<String, Object?> toJson() => compact({
        'clientRef': clientRef,
        'category': category?.wire,
        'description': description?.trim(),
        'amount': amount,
        'expenseDate': expenseDate == null ? null : formatDateOnly(expenseDate!),
        'notes': notes?.trim(),
      });
}

class ExpenseRepository {
  ExpenseRepository(this._dio);

  final Dio _dio;

  Future<List<Expense>> list(int cropId) => guard(() async {
        final res = await _dio.get<List<dynamic>>('/crops/$cropId/expenses');
        return res.data!.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
      });

  Future<Expense> add(int cropId, ExpenseInput input) => guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/crops/$cropId/expenses', data: input.toJson());
        return Expense.fromJson(res.data!);
      });

  Future<Expense> update(int cropId, int expenseId, ExpenseInput input) => guard(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          '/crops/$cropId/expenses/$expenseId',
          data: input.toJson(),
        );
        return Expense.fromJson(res.data!);
      });

  Future<void> delete(int cropId, int expenseId) =>
      guard(() => _dio.delete<void>('/crops/$cropId/expenses/$expenseId'));
}
