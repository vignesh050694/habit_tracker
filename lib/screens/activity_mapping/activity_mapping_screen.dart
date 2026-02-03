import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity_mapping.dart';
import '../../providers/activity_mapping_provider.dart';
import '../../providers/habit_provider.dart';
import 'add_mapping_dialog.dart';

class ActivityMappingScreen extends StatelessWidget {
  const ActivityMappingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Routines'),
      ),
      body: Consumer2<ActivityMappingProvider, HabitProvider>(
        builder: (context, mappingProvider, habitProvider, _) {
          if (mappingProvider.isLoading && mappingProvider.mappings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mappingProvider.mappings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link_off,
                        size: 80,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No Activity Mappings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map your habits to your daily routine.\n'
                      'For example: "After brushing teeth → Read 20 pages"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => mappingProvider.loadMappings(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: mappingProvider.mappings.length,
              itemBuilder: (context, index) {
                final mapping = mappingProvider.mappings[index];
                return _buildMappingCard(
                    context, mapping, mappingProvider, habitProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMappingCard(
    BuildContext context,
    ActivityMapping mapping,
    ActivityMappingProvider mappingProvider,
    HabitProvider habitProvider,
  ) {
    final habit = habitProvider.habits
        .where((h) => h.id == mapping.habitId)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trigger
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mapping.triggerActivity,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Arrow and action
                      Row(
                        children: [
                          Icon(Icons.arrow_forward,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mapping.mappedAction,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),

                      // Linked habit
                      if (habit != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(Icons.check_circle_outline,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              habit.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: mapping.isActive,
                      onChanged: (_) =>
                          mappingProvider.toggleMappingActive(mapping.id),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, mapping);
                        } else if (value == 'delete') {
                          _confirmDelete(context, mapping);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (mapping.notes != null && mapping.notes!.isNotEmpty) ...[
              const Divider(),
              Text(
                mapping.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddMappingDialog(),
    );
  }

  void _showEditDialog(BuildContext context, ActivityMapping mapping) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddMappingDialog(existingMapping: mapping),
    );
  }

  void _confirmDelete(BuildContext context, ActivityMapping mapping) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mapping'),
        content: Text(
            'Delete the mapping "${mapping.triggerActivity} → ${mapping.mappedAction}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context
                  .read<ActivityMappingProvider>()
                  .deleteMapping(mapping.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
