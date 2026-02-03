import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import 'morning_entry_dialog.dart';
import 'evening_reflection_dialog.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadEntries(),
            child: CustomScrollView(
              slivers: [
                // Today's journal card
                SliverToBoxAdapter(
                  child: _buildTodayCard(context, provider),
                ),

                // Past entries
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Past Entries',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),

                if (provider.entries.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No journal entries yet'),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = provider.entries[index];
                        return _buildEntryTile(context, entry);
                      },
                      childCount: provider.entries.length,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<JournalProvider>(
        builder: (context, provider, _) {
          if (provider.todayEntry != null) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showMorningEntryDialog(context),
            icon: const Icon(Icons.wb_sunny_outlined),
            label: const Text('Morning Journal'),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, JournalProvider provider) {
    final today = provider.todayEntry;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Today's Journal",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (today != null) _buildStatusChip(context, today.status),
              ],
            ),
            const SizedBox(height: 12),
            if (today == null) ...[
              Text(
                'Start your day with a morning journal entry.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ] else ...[
              Text(
                'Morning:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                today.morningEntry,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (today.eveningReflection != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Evening Reflection:',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  today.eveningReflection!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (today.eveningReflection == null)
                    FilledButton.icon(
                      onPressed: () =>
                          _showEveningReflectionDialog(context, today),
                      icon: const Icon(Icons.nights_stay_outlined),
                      label: const Text('Add Evening Reflection'),
                    ),
                  const Spacer(),
                  if (today.status != 'completed')
                    TextButton(
                      onPressed: () => _updateStatus(context, today),
                      child: const Text('Update Status'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    String label;
    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
    }
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEntryTile(BuildContext context, JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            DateFormat('d').format(entry.date),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          DateFormat('EEEE, MMM d').format(entry.date),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          entry.morningEntry,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entry.mood != null) _buildMoodIcon(entry.mood!),
            const SizedBox(width: 4),
            _buildStatusChip(context, entry.status),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalDetailScreen(entry: entry),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodIcon(String mood) {
    IconData icon;
    Color color;
    switch (mood) {
      case 'great':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'good':
        icon = Icons.sentiment_satisfied;
        color = Colors.lightGreen;
        break;
      case 'okay':
        icon = Icons.sentiment_neutral;
        color = Colors.amber;
        break;
      case 'bad':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.orange;
        break;
      case 'terrible':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }
    return Icon(icon, color: color, size: 20);
  }

  void _showMorningEntryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const MorningEntryDialog(),
    );
  }

  void _showEveningReflectionDialog(
      BuildContext context, JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EveningReflectionDialog(entry: entry),
    );
  }

  void _updateStatus(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pending, color: Colors.grey),
              title: const Text('Pending'),
              onTap: () {
                context
                    .read<JournalProvider>()
                    .updateEntryStatus(entry.id, 'pending');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timelapse, color: Colors.orange),
              title: const Text('In Progress'),
              onTap: () {
                context
                    .read<JournalProvider>()
                    .updateEntryStatus(entry.id, 'in_progress');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Completed'),
              onTap: () {
                context
                    .read<JournalProvider>()
                    .updateEntryStatus(entry.id, 'completed');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
