import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../services/supabase_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseCategory> _categories = [];
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedMonth = DateTime.now();

  List<ExpenseCategory> get categories => _categories;
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;

  double get totalExpensesForMonth {
    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    return _expenses
        .where((e) =>
            e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final expense in _expenses) {
      map[expense.categoryId] =
          (map[expense.categoryId] ?? 0) + expense.amount;
    }
    return map;
  }

  String getCategoryName(String categoryId) {
    final category = _categories.where((c) => c.id == categoryId).firstOrNull;
    return category?.name ?? 'Unknown';
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
    loadExpenses();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await SupabaseService.getExpenseCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      _expenses = await SupabaseService.getExpenses(
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await loadCategories();
    await loadExpenses();
  }

  Future<void> createCategory({
    required String name,
    String? icon,
    String? color,
  }) async {
    try {
      final category = ExpenseCategory(
        id: const Uuid().v4(),
        name: name,
        icon: icon,
        color: color,
        createdAt: DateTime.now(),
      );
      final created = await SupabaseService.createExpenseCategory(category);
      _categories.add(created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    try {
      final updated = await SupabaseService.updateExpenseCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index >= 0) {
        _categories[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await SupabaseService.deleteExpenseCategory(id);
      _categories.removeWhere((c) => c.id == id);
      _expenses.removeWhere((e) => e.categoryId == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createExpense({
    required String categoryId,
    required double amount,
    String? description,
    DateTime? date,
  }) async {
    try {
      final expense = Expense(
        id: const Uuid().v4(),
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
      );
      final created = await SupabaseService.createExpense(expense);
      _expenses.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      final updated = await SupabaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index >= 0) {
        _expenses[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await SupabaseService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
