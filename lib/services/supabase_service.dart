import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/activity_mapping.dart';
import '../models/expense.dart';
import '../models/manifestation.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Habits ──────────────────────────────────────────────

  static Future<List<Habit>> getHabits() async {
    final response = await _client
        .from('habits')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => Habit.fromJson(e)).toList();
  }

  static Future<Habit> createHabit(Habit habit) async {
    final response =
        await _client.from('habits').insert(habit.toJson()).select().single();
    return Habit.fromJson(response);
  }

  static Future<Habit> updateHabit(Habit habit) async {
    final response = await _client
        .from('habits')
        .update(habit.toJson())
        .eq('id', habit.id)
        .select()
        .single();
    return Habit.fromJson(response);
  }

  static Future<void> deleteHabit(String id) async {
    await _client.from('habits').delete().eq('id', id);
  }

  // ─── Habit Logs ──────────────────────────────────────────

  static Future<List<HabitLog>> getHabitLogs({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _client.from('habit_logs').select().eq('habit_id', habitId);

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('date', ascending: false);
    return (response as List).map((e) => HabitLog.fromJson(e)).toList();
  }

  static Future<List<HabitLog>> getHabitLogsForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response =
        await _client.from('habit_logs').select().eq('date', dateStr);
    return (response as List).map((e) => HabitLog.fromJson(e)).toList();
  }

  static Future<HabitLog> upsertHabitLog(HabitLog log) async {
    final response = await _client
        .from('habit_logs')
        .upsert(log.toJson(), onConflict: 'habit_id,date')
        .select()
        .single();
    return HabitLog.fromJson(response);
  }

  // ─── Journal Entries ─────────────────────────────────────

  static Future<List<JournalEntry>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _client.from('journal_entries').select();

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('date', ascending: false);
    return (response as List).map((e) => JournalEntry.fromJson(e)).toList();
  }

  static Future<JournalEntry?> getJournalEntryForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _client
        .from('journal_entries')
        .select()
        .eq('date', dateStr)
        .maybeSingle();
    return response != null ? JournalEntry.fromJson(response) : null;
  }

  static Future<JournalEntry> createJournalEntry(JournalEntry entry) async {
    final response = await _client
        .from('journal_entries')
        .insert(entry.toJson())
        .select()
        .single();
    return JournalEntry.fromJson(response);
  }

  static Future<JournalEntry> updateJournalEntry(JournalEntry entry) async {
    final response = await _client
        .from('journal_entries')
        .update(entry.toJson())
        .eq('id', entry.id)
        .select()
        .single();
    return JournalEntry.fromJson(response);
  }

  static Future<void> deleteJournalEntry(String id) async {
    await _client.from('journal_entries').delete().eq('id', id);
  }

  // ─── Activity Mappings ───────────────────────────────────

  static Future<List<ActivityMapping>> getActivityMappings() async {
    final response = await _client
        .from('activity_mappings')
        .select()
        .order('sort_order', ascending: true);
    return (response as List).map((e) => ActivityMapping.fromJson(e)).toList();
  }

  static Future<ActivityMapping> createActivityMapping(
      ActivityMapping mapping) async {
    final response = await _client
        .from('activity_mappings')
        .insert(mapping.toJson())
        .select()
        .single();
    return ActivityMapping.fromJson(response);
  }

  static Future<ActivityMapping> updateActivityMapping(
      ActivityMapping mapping) async {
    final response = await _client
        .from('activity_mappings')
        .update(mapping.toJson())
        .eq('id', mapping.id)
        .select()
        .single();
    return ActivityMapping.fromJson(response);
  }

  static Future<void> deleteActivityMapping(String id) async {
    await _client.from('activity_mappings').delete().eq('id', id);
  }

  // ─── Expense Categories ──────────────────────────────────

  static Future<List<ExpenseCategory>> getExpenseCategories() async {
    final response = await _client
        .from('expense_categories')
        .select()
        .order('name', ascending: true);
    return (response as List).map((e) => ExpenseCategory.fromJson(e)).toList();
  }

  static Future<ExpenseCategory> createExpenseCategory(
      ExpenseCategory category) async {
    final response = await _client
        .from('expense_categories')
        .insert(category.toJson())
        .select()
        .single();
    return ExpenseCategory.fromJson(response);
  }

  static Future<ExpenseCategory> updateExpenseCategory(
      ExpenseCategory category) async {
    final response = await _client
        .from('expense_categories')
        .update(category.toJson())
        .eq('id', category.id)
        .select()
        .single();
    return ExpenseCategory.fromJson(response);
  }

  static Future<void> deleteExpenseCategory(String id) async {
    await _client.from('expense_categories').delete().eq('id', id);
  }

  // ─── Expenses ────────────────────────────────────────────

  static Future<List<Expense>> getExpenses({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _client.from('expenses').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('date', ascending: false);
    return (response as List).map((e) => Expense.fromJson(e)).toList();
  }

  static Future<Expense> createExpense(Expense expense) async {
    final response = await _client
        .from('expenses')
        .insert(expense.toJson())
        .select()
        .single();
    return Expense.fromJson(response);
  }

  static Future<Expense> updateExpense(Expense expense) async {
    final response = await _client
        .from('expenses')
        .update(expense.toJson())
        .eq('id', expense.id)
        .select()
        .single();
    return Expense.fromJson(response);
  }

  static Future<void> deleteExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }

  // ─── Manifestations ─────────────────────────────────────

  static Future<List<Manifestation>> getManifestations() async {
    final response = await _client
        .from('manifestations')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => Manifestation.fromJson(e)).toList();
  }

  static Future<Manifestation> createManifestation(
      Manifestation manifestation) async {
    final response = await _client
        .from('manifestations')
        .insert(manifestation.toJson())
        .select()
        .single();
    return Manifestation.fromJson(response);
  }

  static Future<Manifestation> updateManifestation(
      Manifestation manifestation) async {
    final response = await _client
        .from('manifestations')
        .update(manifestation.toJson())
        .eq('id', manifestation.id)
        .select()
        .single();
    return Manifestation.fromJson(response);
  }

  static Future<void> deleteManifestation(String id) async {
    await _client.from('manifestations').delete().eq('id', id);
  }

  // ─── Manifestation Practices ────────────────────────────

  static Future<List<ManifestationPractice>> getManifestationPractices(
      String manifestationId) async {
    final response = await _client
        .from('manifestation_practices')
        .select()
        .eq('manifestation_id', manifestationId)
        .order('date', ascending: false);
    return (response as List)
        .map((e) => ManifestationPractice.fromJson(e))
        .toList();
  }

  static Future<ManifestationPractice> upsertManifestationPractice(
      ManifestationPractice practice) async {
    final response = await _client
        .from('manifestation_practices')
        .upsert(practice.toJson(), onConflict: 'manifestation_id,date')
        .select()
        .single();
    return ManifestationPractice.fromJson(response);
  }

  // ─── Manifestation Signs ────────────────────────────────

  static Future<List<ManifestationSign>> getManifestationSigns(
      String manifestationId) async {
    final response = await _client
        .from('manifestation_signs')
        .select()
        .eq('manifestation_id', manifestationId)
        .order('date', ascending: false);
    return (response as List)
        .map((e) => ManifestationSign.fromJson(e))
        .toList();
  }

  static Future<ManifestationSign> createManifestationSign(
      ManifestationSign sign) async {
    final response = await _client
        .from('manifestation_signs')
        .insert(sign.toJson())
        .select()
        .single();
    return ManifestationSign.fromJson(response);
  }

  static Future<void> deleteManifestationSign(String id) async {
    await _client.from('manifestation_signs').delete().eq('id', id);
  }
}
