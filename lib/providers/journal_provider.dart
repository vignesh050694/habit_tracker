import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry.dart';
import '../services/supabase_service.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  JournalEntry? _todayEntry;
  bool _isLoading = false;
  String? _error;

  List<JournalEntry> get entries => _entries;
  JournalEntry? get todayEntry => _todayEntry;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await SupabaseService.getJournalEntries();
      _todayEntry = await SupabaseService.getJournalEntryForDate(DateTime.now());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayEntry() async {
    try {
      _todayEntry = await SupabaseService.getJournalEntryForDate(DateTime.now());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createMorningEntry({
    required String morningEntry,
    List<String>? tags,
  }) async {
    try {
      final entry = JournalEntry(
        id: const Uuid().v4(),
        date: DateTime.now(),
        morningEntry: morningEntry,
        status: 'pending',
        tags: tags,
        createdAt: DateTime.now(),
      );
      final created = await SupabaseService.createJournalEntry(entry);
      _entries.insert(0, created);
      _todayEntry = created;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEveningReflection({
    required String entryId,
    required String eveningReflection,
    required String status,
    String? mood,
  }) async {
    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      final updated = entry.copyWith(
        eveningReflection: eveningReflection,
        status: status,
        mood: mood,
        updatedAt: DateTime.now(),
      );
      final result = await SupabaseService.updateJournalEntry(updated);
      final index = _entries.indexWhere((e) => e.id == entryId);
      if (index >= 0) {
        _entries[index] = result;
      }
      if (_todayEntry?.id == entryId) {
        _todayEntry = result;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEntryStatus(String entryId, String status) async {
    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      final updated = entry.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      final result = await SupabaseService.updateJournalEntry(updated);
      final index = _entries.indexWhere((e) => e.id == entryId);
      if (index >= 0) {
        _entries[index] = result;
      }
      if (_todayEntry?.id == entryId) {
        _todayEntry = result;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await SupabaseService.deleteJournalEntry(id);
      _entries.removeWhere((e) => e.id == id);
      if (_todayEntry?.id == id) {
        _todayEntry = null;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
