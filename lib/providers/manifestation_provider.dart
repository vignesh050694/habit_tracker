import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/manifestation.dart';
import '../services/supabase_service.dart';

class ManifestationProvider extends ChangeNotifier {
  List<Manifestation> _manifestations = [];
  Map<String, List<ManifestationPractice>> _practices = {};
  Map<String, List<ManifestationSign>> _signs = {};
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all'; // all, active, manifesting, manifested, released

  List<Manifestation> get manifestations {
    if (_filterStatus == 'all') return _manifestations;
    return _manifestations.where((m) => m.status == _filterStatus).toList();
  }

  List<Manifestation> get allManifestations => _manifestations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  int get activeCount =>
      _manifestations.where((m) => m.status == 'active').length;
  int get manifestingCount =>
      _manifestations.where((m) => m.status == 'manifesting').length;
  int get manifestedCount =>
      _manifestations.where((m) => m.status == 'manifested').length;

  List<ManifestationPractice> getPractices(String manifestationId) =>
      _practices[manifestationId] ?? [];

  List<ManifestationSign> getSigns(String manifestationId) =>
      _signs[manifestationId] ?? [];

  /// Check if today's practice is done for a manifestation
  bool isTodayPracticeDone(String manifestationId) {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final practices = _practices[manifestationId] ?? [];
    return practices.any((p) {
      final pDateStr =
          '${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}';
      return pDateStr == todayStr && (p.affirmed || p.visualized);
    });
  }

  /// Get practice streak for a manifestation
  int getPracticeStreak(String manifestationId) {
    final practices = (_practices[manifestationId] ?? [])
        .where((p) => p.affirmed || p.visualized)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (practices.isEmpty) return 0;

    int streak = 0;
    var checkDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final dateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final found = practices.any((p) {
        final pDateStr =
            '${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}';
        return pDateStr == dateStr;
      });

      if (found) {
        streak++;
      } else if (i > 0) {
        break;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> loadManifestations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _manifestations = await SupabaseService.getManifestations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPractices(String manifestationId) async {
    try {
      final practices =
          await SupabaseService.getManifestationPractices(manifestationId);
      _practices[manifestationId] = practices;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSigns(String manifestationId) async {
    try {
      final signs =
          await SupabaseService.getManifestationSigns(manifestationId);
      _signs[manifestationId] = signs;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadManifestationDetails(String manifestationId) async {
    await Future.wait([
      loadPractices(manifestationId),
      loadSigns(manifestationId),
    ]);
  }

  Future<void> createManifestation({
    required String affirmation,
    String? description,
    required String category,
    DateTime? targetDate,
  }) async {
    try {
      final manifestation = Manifestation(
        id: const Uuid().v4(),
        affirmation: affirmation,
        description: description,
        category: category,
        status: 'active',
        targetDate: targetDate,
        createdAt: DateTime.now(),
      );
      final created =
          await SupabaseService.createManifestation(manifestation);
      _manifestations.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateManifestation(Manifestation manifestation) async {
    try {
      final updated =
          await SupabaseService.updateManifestation(manifestation);
      final index = _manifestations.indexWhere((m) => m.id == manifestation.id);
      if (index >= 0) {
        _manifestations[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final index = _manifestations.indexWhere((m) => m.id == id);
    if (index < 0) return;

    final updated = _manifestations[index].copyWith(
      status: newStatus,
      manifestedAt: newStatus == 'manifested' ? DateTime.now() : null,
    );

    await updateManifestation(updated);
  }

  Future<void> deleteManifestation(String id) async {
    try {
      await SupabaseService.deleteManifestation(id);
      _manifestations.removeWhere((m) => m.id == id);
      _practices.remove(id);
      _signs.remove(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logPractice({
    required String manifestationId,
    required bool affirmed,
    required bool visualized,
    String? gratitudeNote,
  }) async {
    try {
      final practice = ManifestationPractice(
        id: const Uuid().v4(),
        manifestationId: manifestationId,
        date: DateTime.now(),
        affirmed: affirmed,
        visualized: visualized,
        gratitudeNote: gratitudeNote,
        createdAt: DateTime.now(),
      );
      final created =
          await SupabaseService.upsertManifestationPractice(practice);
      final list = _practices[manifestationId] ?? [];
      // Remove existing practice for today if any
      final today = DateTime.now();
      list.removeWhere((p) =>
          p.date.year == today.year &&
          p.date.month == today.month &&
          p.date.day == today.day);
      list.insert(0, created);
      _practices[manifestationId] = list;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSign({
    required String manifestationId,
    required String description,
  }) async {
    try {
      final sign = ManifestationSign(
        id: const Uuid().v4(),
        manifestationId: manifestationId,
        description: description,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      final created = await SupabaseService.createManifestationSign(sign);
      final list = _signs[manifestationId] ?? [];
      list.insert(0, created);
      _signs[manifestationId] = list;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSign(String manifestationId, String signId) async {
    try {
      await SupabaseService.deleteManifestationSign(signId);
      _signs[manifestationId]?.removeWhere((s) => s.id == signId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
