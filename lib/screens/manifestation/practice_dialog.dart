import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/manifestation_provider.dart';

class PracticeDialog extends StatefulWidget {
  final String manifestationId;

  const PracticeDialog({super.key, required this.manifestationId});

  @override
  State<PracticeDialog> createState() => _PracticeDialogState();
}

class _PracticeDialogState extends State<PracticeDialog> {
  bool _affirmed = false;
  bool _visualized = false;
  final _gratitudeController = TextEditingController();

  @override
  void dispose() {
    _gratitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.self_improvement, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Daily Practice',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What did you do today for this manifestation?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 20),

          // Affirmed
          CheckboxListTile(
            value: _affirmed,
            onChanged: (v) => setState(() => _affirmed = v ?? false),
            title: const Text('I affirmed this today'),
            subtitle: const Text('Spoke or wrote the affirmation'),
            secondary: const Icon(Icons.format_quote, color: Colors.blue),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 8),

          // Visualized
          CheckboxListTile(
            value: _visualized,
            onChanged: (v) => setState(() => _visualized = v ?? false),
            title: const Text('I visualized this today'),
            subtitle: const Text('Spent time seeing it as real'),
            secondary: const Icon(Icons.visibility, color: Colors.purple),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 16),

          // Gratitude note
          TextField(
            controller: _gratitudeController,
            decoration: const InputDecoration(
              labelText: 'Gratitude note (optional)',
              hintText: 'What are you grateful for related to this?',
              prefixIcon: Icon(Icons.favorite, color: Colors.pink),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: (_affirmed || _visualized) ? _submit : null,
            icon: const Icon(Icons.check),
            label: const Text('Log Practice'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    try {
      await context.read<ManifestationProvider>().logPractice(
            manifestationId: widget.manifestationId,
            affirmed: _affirmed,
            visualized: _visualized,
            gratitudeNote: _gratitudeController.text.trim().isNotEmpty
                ? _gratitudeController.text.trim()
                : null,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
