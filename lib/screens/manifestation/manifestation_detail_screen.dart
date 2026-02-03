import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/manifestation.dart';
import '../../providers/manifestation_provider.dart';
import 'practice_dialog.dart';

class ManifestationDetailScreen extends StatefulWidget {
  final Manifestation manifestation;

  const ManifestationDetailScreen({super.key, required this.manifestation});

  @override
  State<ManifestationDetailScreen> createState() =>
      _ManifestationDetailScreenState();
}

class _ManifestationDetailScreenState extends State<ManifestationDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ManifestationProvider>()
        .loadManifestationDetails(widget.manifestation.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManifestationProvider>(
      builder: (context, provider, _) {
        // Get latest version
        final m = provider.allManifestations
                .where((x) => x.id == widget.manifestation.id)
                .firstOrNull ??
            widget.manifestation;
        final practices = provider.getPractices(m.id);
        final signs = provider.getSigns(m.id);
        final streak = provider.getPracticeStreak(m.id);
        final todayDone = provider.isTodayPracticeDone(m.id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manifestation'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, m),
                itemBuilder: (_) => [
                  if (m.status == 'active')
                    const PopupMenuItem(
                        value: 'manifesting',
                        child: Text('Mark as Manifesting')),
                  if (m.status != 'manifested')
                    const PopupMenuItem(
                        value: 'manifested',
                        child: Text('Mark as Manifested')),
                  if (m.status != 'released')
                    const PopupMenuItem(
                        value: 'released', child: Text('Release')),
                  if (m.status != 'active')
                    const PopupMenuItem(
                        value: 'active', child: Text('Reactivate')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Affirmation card
                Card(
                  margin: EdgeInsets.zero,
                  color: Colors.purple.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.purple, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          '"${m.affirmation}"',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      icon: Icons.local_fire_department,
                      label: 'Practice Streak',
                      value: '$streak days',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      icon: Icons.visibility,
                      label: 'Signs Logged',
                      value: '${signs.length}',
                      color: Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status and category
                Row(
                  children: [
                    _buildStatusChip(m.status),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(Manifestation.categoryLabel(m.category)),
                      avatar: const Icon(Icons.category, size: 16),
                    ),
                  ],
                ),

                if (m.description != null) ...[
                  const SizedBox(height: 16),
                  Text('Vision',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(m.description!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],

                if (m.targetDate != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Target: ${DateFormat('MMMM d, yyyy').format(m.targetDate!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],

                // Today's practice
                if (m.status != 'manifested' && m.status != 'released') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's Practice",
                          style: Theme.of(context).textTheme.titleMedium),
                      if (todayDone)
                        const Chip(
                          label: Text('Done'),
                          avatar:
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                          backgroundColor: Color(0x1A4CAF50),
                          side: BorderSide.none,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!todayDone)
                    FilledButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) =>
                              PracticeDialog(manifestationId: m.id),
                        );
                      },
                      icon: const Icon(Icons.self_improvement),
                      label: const Text('Log Practice'),
                    )
                  else
                    _buildTodayPracticeSummary(context, practices),
                ],

                // Signs & Synchronicities
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Signs & Synchronicities',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: () => _showAddSignDialog(context, m.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (signs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No signs logged yet. When you notice synchronicities or progress, log them here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  )
                else
                  ...signs.map((sign) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.visibility,
                              color: Colors.teal),
                          title: Text(sign.description),
                          subtitle: Text(
                            DateFormat('MMM d, yyyy').format(sign.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () =>
                                provider.deleteSign(m.id, sign.id),
                          ),
                        ),
                      )),

                // Practice history
                if (practices.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Practice History',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...practices.take(10).map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            p.affirmed && p.visualized
                                ? Icons.done_all
                                : Icons.done,
                            color: Colors.green,
                            size: 20,
                          ),
                          title: Text(
                            DateFormat('MMM d, yyyy').format(p.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            [
                              if (p.affirmed) 'Affirmed',
                              if (p.visualized) 'Visualized',
                            ].join(' + '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: p.gratitudeNote != null
                              ? const Icon(Icons.favorite,
                                  color: Colors.pink, size: 16)
                              : null,
                        ),
                      )),
                ],

                const SizedBox(height: 16),
                Text(
                  'Created ${DateFormat('MMMM d, yyyy').format(m.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                if (m.manifestedAt != null)
                  Text(
                    'Manifested ${DateFormat('MMMM d, yyyy').format(m.manifestedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'active':
        color = Colors.blue;
        icon = Icons.auto_awesome;
        break;
      case 'manifesting':
        color = Colors.purple;
        icon = Icons.stars;
        break;
      case 'manifested':
        color = Colors.green;
        icon = Icons.celebration;
        break;
      case 'released':
        color = Colors.grey;
        icon = Icons.cloud_off;
        break;
      default:
        color = Colors.blue;
        icon = Icons.auto_awesome;
    }
    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(Manifestation.statusLabel(status)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildTodayPracticeSummary(
      BuildContext context, List<ManifestationPractice> practices) {
    final today = DateTime.now();
    final todayPractice = practices
        .where((p) =>
            p.date.year == today.year &&
            p.date.month == today.month &&
            p.date.day == today.day)
        .firstOrNull;

    if (todayPractice == null) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.green.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (todayPractice.affirmed)
                  const Chip(
                    label: Text('Affirmed'),
                    avatar: Icon(Icons.format_quote, size: 14),
                    visualDensity: VisualDensity.compact,
                  ),
                if (todayPractice.affirmed && todayPractice.visualized)
                  const SizedBox(width: 8),
                if (todayPractice.visualized)
                  const Chip(
                    label: Text('Visualized'),
                    avatar: Icon(Icons.visibility, size: 14),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (todayPractice.gratitudeNote != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      todayPractice.gratitudeNote!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Manifestation m) {
    if (action == 'delete') {
      _confirmDelete(m);
    } else {
      context.read<ManifestationProvider>().updateStatus(m.id, action);
    }
  }

  void _confirmDelete(Manifestation m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Manifestation'),
        content:
            const Text('Are you sure? This will also remove all practice logs and signs.'),
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
              await context
                  .read<ManifestationProvider>()
                  .deleteManifestation(m.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddSignDialog(BuildContext context, String manifestationId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log a Sign'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'What did you notice?',
            labelText: 'Sign or synchronicity',
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await context.read<ManifestationProvider>().addSign(
                    manifestationId: manifestationId,
                    description: controller.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
