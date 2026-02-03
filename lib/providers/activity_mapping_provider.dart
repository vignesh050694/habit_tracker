import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_mapping.dart';
import '../services/supabase_service.dart';

class ActivityMappingProvider extends ChangeNotifier {
  List<ActivityMapping> _mappings = [];
  bool _isLoading = false;
  String? _error;

  List<ActivityMapping> get mappings => _mappings;
  List<ActivityMapping> get activeMappings =>
      _mappings.where((m) => m.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ActivityMapping> getMappingsForHabit(String habitId) {
    return _mappings.where((m) => m.habitId == habitId).toList();
  }

  Future<void> loadMappings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mappings = await SupabaseService.getActivityMappings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMapping({
    required String triggerActivity,
    required String habitId,
    required String mappedAction,
    String? notes,
  }) async {
    try {
      final mapping = ActivityMapping(
        id: const Uuid().v4(),
        triggerActivity: triggerActivity,
        habitId: habitId,
        mappedAction: mappedAction,
        notes: notes,
        sortOrder: _mappings.length,
        createdAt: DateTime.now(),
      );
      final created = await SupabaseService.createActivityMapping(mapping);
      _mappings.add(created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMapping(ActivityMapping mapping) async {
    try {
      final updated = await SupabaseService.updateActivityMapping(mapping);
      final index = _mappings.indexWhere((m) => m.id == mapping.id);
      if (index >= 0) {
        _mappings[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMapping(String id) async {
    try {
      await SupabaseService.deleteActivityMapping(id);
      _mappings.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleMappingActive(String id) async {
    try {
      final mapping = _mappings.firstWhere((m) => m.id == id);
      final updated = mapping.copyWith(isActive: !mapping.isActive);
      await updateMapping(updated);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
