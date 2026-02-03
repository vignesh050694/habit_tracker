import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';

class EveningReflectionDialog extends StatefulWidget {
  final JournalEntry entry;

  const EveningReflectionDialog({super.key, required this.entry});

  @override
  State<EveningReflectionDialog> createState() =>
      _EveningReflectionDialogState();
}

class _EveningReflectionDialogState extends State<EveningReflectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reflectionController = TextEditingController();
  String _selectedMood = 'good';
  String _selectedStatus = 'completed';

  final List<Map<String, dynamic>> _moods = [
    {'value': 'great', 'label': 'Great', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'value': 'good', 'label': 'Good', 'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen},
    {'value': 'okay', 'label': 'Okay', 'icon': Icons.sentiment_neutral, 'color': Colors.amber},
    {'value': 'bad', 'label': 'Bad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.orange},
    {'value': 'terrible', 'label': 'Terrible', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
  ];

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nights_stay,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Evening Reflection',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Reflect on your day. How did it go?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 16),

              // Mood selector
              Text('How are you feeling?',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood['value'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMood = mood['value'] as String),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? (mood['color'] as Color).withValues(alpha: 0.2)
                                : null,
                            border: isSelected
                                ? Border.all(
                                    color: mood['color'] as Color, width: 2)
                                : null,
                          ),
                          child: Icon(
                            mood['icon'] as IconData,
                            color: mood['color'] as Color,
                            size: isSelected ? 32 : 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _reflectionController,
                decoration: const InputDecoration(
                  labelText: 'Evening Reflection',
                  hintText: 'What went well? What could be improved?',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Reflection is required'
                    : null,
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Status
              Text("Today's Status",
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'pending',
                    label: Text('Pending'),
                    icon: Icon(Icons.pending),
                  ),
                  ButtonSegment(
                    value: 'in_progress',
                    label: Text('In Progress'),
                    icon: Icon(Icons.timelapse),
                  ),
                  ButtonSegment(
                    value: 'completed',
                    label: Text('Done'),
                    icon: Icon(Icons.check_circle),
                  ),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (selected) {
                  setState(() => _selectedStatus = selected.first);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('Save Reflection'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<JournalProvider>().updateEveningReflection(
            entryId: widget.entry.id,
            eveningReflection: _reflectionController.text.trim(),
            status: _selectedStatus,
            mood: _selectedMood,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reflection: $e')),
        );
      }
    }
  }
}
