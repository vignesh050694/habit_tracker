import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import 'evening_reflection_dialog.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, MMM d').format(entry.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, _) {
          // Get latest version from provider
          final current = provider.entries
              .where((e) => e.id == entry.id)
              .firstOrNull ?? entry;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and mood row
                Row(
                  children: [
                    _buildStatusChip(context, current.status),
                    const SizedBox(width: 8),
                    if (current.mood != null)
                      _buildMoodChip(context, current.mood!),
                  ],
                ),
                const SizedBox(height: 24),

                // Morning entry
                Row(
                  children: [
                    Icon(Icons.wb_sunny,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20),
                    const SizedBox(width: 8),
                    Text('Morning Entry',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        current.morningEntry,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Evening reflection
                Row(
                  children: [
                    Icon(Icons.nights_stay,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20),
                    const SizedBox(width: 8),
                    Text('Evening Reflection',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                if (current.eveningReflection != null)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          current.eveningReflection!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'No evening reflection yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (_) =>
                                    EveningReflectionDialog(entry: current),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Reflection'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tags
                if (current.tags != null && current.tags!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Tags',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: current.tags!.map((tag) {
                      return Chip(label: Text(tag));
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        icon = Icons.check_circle;
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        icon = Icons.timelapse;
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
        icon = Icons.pending;
    }
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildMoodChip(BuildContext context, String mood) {
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
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(mood[0].toUpperCase() + mood.substring(1)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
            'Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await context.read<JournalProvider>().deleteEntry(entry.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
