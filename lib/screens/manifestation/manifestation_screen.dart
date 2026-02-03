import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/manifestation.dart';
import '../../providers/manifestation_provider.dart';
import 'add_manifestation_dialog.dart';
import 'manifestation_detail_screen.dart';

class ManifestationScreen extends StatelessWidget {
  const ManifestationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manifest'),
      ),
      body: Consumer<ManifestationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allManifestations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadManifestations(),
            child: CustomScrollView(
              slivers: [
                // Stats summary
                SliverToBoxAdapter(
                  child: _buildStatsRow(context, provider),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: _buildFilterChips(context, provider),
                ),

                // List
                if (provider.manifestations.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No manifestations yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by writing your first affirmation',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final m = provider.manifestations[index];
                        return _buildManifestationCard(context, provider, m);
                      },
                      childCount: provider.manifestations.length,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const AddManifestationDialog(),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('New Manifestation'),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ManifestationProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _buildStatChip(
            context,
            label: 'Active',
            count: provider.activeCount,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            context,
            label: 'Manifesting',
            count: provider.manifestingCount,
            color: Colors.purple,
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            context,
            label: 'Manifested',
            count: provider.manifestedCount,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, ManifestationProvider provider) {
    final filters = ['all', 'active', 'manifesting', 'manifested', 'released'];
    final labels = ['All', 'Active', 'Manifesting', 'Manifested', 'Released'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            final isSelected = provider.filterStatus == filters[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(labels[i]),
                onSelected: (_) => provider.setFilter(filters[i]),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildManifestationCard(
    BuildContext context,
    ManifestationProvider provider,
    Manifestation m,
  ) {
    final todayDone = provider.isTodayPracticeDone(m.id);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManifestationDetailScreen(manifestation: m),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(m.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.affirmation,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                  if (todayDone)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      Manifestation.categoryLabel(m.category),
                      style: const TextStyle(fontSize: 11),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      Manifestation.statusLabel(m.status),
                      style: const TextStyle(fontSize: 11),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        _statusColor(m.status).withValues(alpha: 0.15),
                  ),
                  const Spacer(),
                  if (!todayDone && m.status != 'manifested' && m.status != 'released')
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManifestationDetailScreen(manifestation: m),
                          ),
                        );
                      },
                      icon: const Icon(Icons.self_improvement, size: 16),
                      label: const Text('Practice'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'active':
        return const Icon(Icons.auto_awesome, color: Colors.blue, size: 20);
      case 'manifesting':
        return const Icon(Icons.stars, color: Colors.purple, size: 20);
      case 'manifested':
        return const Icon(Icons.celebration, color: Colors.green, size: 20);
      case 'released':
        return const Icon(Icons.cloud_off, color: Colors.grey, size: 20);
      default:
        return const Icon(Icons.auto_awesome, size: 20);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blue;
      case 'manifesting':
        return Colors.purple;
      case 'manifested':
        return Colors.green;
      case 'released':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
