import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity_mapping.dart';
import '../../models/habit.dart';
import '../../providers/activity_mapping_provider.dart';
import '../../providers/habit_provider.dart';

class AddMappingDialog extends StatefulWidget {
  final ActivityMapping? existingMapping;

  const AddMappingDialog({super.key, this.existingMapping});

  @override
  State<AddMappingDialog> createState() => _AddMappingDialogState();
}

class _AddMappingDialogState extends State<AddMappingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _triggerController = TextEditingController();
  final _actionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedHabitId;

  bool get isEditing => widget.existingMapping != null;

  final List<String> _suggestedTriggers = [
    'After waking up',
    'After brushing teeth',
    'After breakfast',
    'After morning coffee',
    'After lunch',
    'After evening snack',
    'After dinner',
    'Before bed',
    'After workout',
    'After commute',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _triggerController.text = widget.existingMapping!.triggerActivity;
      _actionController.text = widget.existingMapping!.mappedAction;
      _notesController.text = widget.existingMapping!.notes ?? '';
      _selectedHabitId = widget.existingMapping!.habitId;
    }
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _actionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.read<HabitProvider>().activeHabits;

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
                  Text(
                    isEditing ? 'Edit Mapping' : 'New Activity Mapping',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Link a habit to your daily routine activity.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 16),

              // Trigger activity
              TextFormField(
                controller: _triggerController,
                decoration: const InputDecoration(
                  labelText: 'Trigger Activity',
                  hintText: 'e.g., After brushing teeth',
                  prefixIcon: Icon(Icons.play_arrow),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Trigger is required'
                    : null,
              ),
              const SizedBox(height: 8),

              // Suggestions
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _suggestedTriggers.map((trigger) {
                  return ActionChip(
                    label: Text(trigger, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _triggerController.text = trigger;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Linked Habit
              DropdownButtonFormField<String>(
                value: _selectedHabitId,
                decoration: const InputDecoration(
                  labelText: 'Link to Habit',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                items: habits.map((Habit habit) {
                  return DropdownMenuItem<String>(
                    value: habit.id,
                    child: Text(habit.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedHabitId = value);
                },
                validator: (v) => v == null ? 'Select a habit' : null,
              ),
              const SizedBox(height: 16),

              // Mapped action
              TextFormField(
                controller: _actionController,
                decoration: const InputDecoration(
                  labelText: 'Action to Do',
                  hintText: 'e.g., Read 20 pages of a book',
                  prefixIcon: Icon(Icons.arrow_forward),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Action is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Any additional details...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Update Mapping' : 'Create Mapping'),
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
      final provider = context.read<ActivityMappingProvider>();
      if (isEditing) {
        final updated = widget.existingMapping!.copyWith(
          triggerActivity: _triggerController.text.trim(),
          habitId: _selectedHabitId!,
          mappedAction: _actionController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        await provider.updateMapping(updated);
      } else {
        await provider.createMapping(
          triggerActivity: _triggerController.text.trim(),
          habitId: _selectedHabitId!,
          mappedAction: _actionController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save mapping: $e')),
        );
      }
    }
  }
}
