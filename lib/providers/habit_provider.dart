import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../services/supabase_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  Map<String, List<HabitLog>> _logsForDate = {};
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  List<HabitLog> getLogsForDate(DateTime date) {
    final key = date.toIso8601String().split('T')[0];
    return _logsForDate[key] ?? [];
  }

  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    final logs = getLogsForDate(date);
    return logs.any((l) => l.habitId == habitId && l.completed);
  }

  int getStreak(String habitId) {
    final logs = _logsForDate.values.expand((l) => l).toList();
    final habitLogs = logs
        .where((l) => l.habitId == habitId && l.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (habitLogs.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (int i = 0; i < 365; i++) {
      final dateStr = checkDate.toIso8601String().split('T')[0];
      final hasLog =
          habitLogs.any((l) => l.date.toIso8601String().split('T')[0] == dateStr);
      if (hasLog) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (i == 0) {
        // Today not yet completed — check from yesterday
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadLogsForDate(date);
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await SupabaseService.getHabits();
      await loadLogsForDate(_selectedDate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLogsForDate(DateTime date) async {
    try {
      final logs = await SupabaseService.getHabitLogsForDate(date);
      final key = date.toIso8601String().split('T')[0];
      _logsForDate[key] = logs;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadLogsForRange(
      String habitId, DateTime start, DateTime end) async {
    try {
      final logs = await SupabaseService.getHabitLogs(
        habitId: habitId,
        startDate: start,
        endDate: end,
      );
      for (final log in logs) {
        final key = log.date.toIso8601String().split('T')[0];
        _logsForDate[key] ??= [];
        final existingIndex =
            _logsForDate[key]!.indexWhere((l) => l.id == log.id);
        if (existingIndex >= 0) {
          _logsForDate[key]![existingIndex] = log;
        } else {
          _logsForDate[key]!.add(log);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createHabit({
    required String name,
    String? description,
    String? icon,
    String frequency = 'daily',
    List<int>? customDays,
  }) async {
    try {
      final habit = Habit(
        id: const Uuid().v4(),
        name: name,
        description: description,
        icon: icon,
        frequency: frequency,
        customDays: customDays,
        createdAt: DateTime.now(),
      );
      final created = await SupabaseService.createHabit(habit);
      _habits.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final updated = await SupabaseService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index >= 0) {
        _habits[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await SupabaseService.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      final key = date.toIso8601String().split('T')[0];
      _logsForDate[key] ??= [];
      final existingLog = _logsForDate[key]!
          .where((l) => l.habitId == habitId)
          .firstOrNull;

      final log = HabitLog(
        id: existingLog?.id ?? const Uuid().v4(),
        habitId: habitId,
        date: date,
        completed: existingLog == null || !existingLog.completed,
      );

      final result = await SupabaseService.upsertHabitLog(log);

      if (existingLog != null) {
        final index = _logsForDate[key]!.indexWhere((l) => l.id == result.id);
        if (index >= 0) {
          _logsForDate[key]![index] = result;
        }
      } else {
        _logsForDate[key]!.add(result);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
