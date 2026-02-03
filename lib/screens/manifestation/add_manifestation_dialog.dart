import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/manifestation.dart';
import '../../providers/manifestation_provider.dart';

class AddManifestationDialog extends StatefulWidget {
  const AddManifestationDialog({super.key});

  @override
  State<AddManifestationDialog> createState() => _AddManifestationDialogState();
}

class _AddManifestationDialogState extends State<AddManifestationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _affirmationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'personal_growth';
  DateTime? _targetDate;

  @override
  void dispose() {
    _affirmationController.dispose();
    _descriptionController.dispose();
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'New Manifestation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Write your affirmation in present tense, as if it has already happened.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 20),

              // Affirmation
              TextFormField(
                controller: _affirmationController,
                decoration: const InputDecoration(
                  labelText: 'Affirmation',
                  hintText: 'I am attracting abundance into my life...',
                  prefixIcon: Icon(Icons.format_quote),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your affirmation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Details (optional)',
                  hintText: 'What does this look like when manifested?',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: Manifestation.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(Manifestation.categoryLabel(cat)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Target date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(_targetDate != null
                    ? 'Target: ${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                    : 'Set a target date (optional)'),
                trailing: _targetDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _targetDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => _targetDate = date);
                  }
                },
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Create Manifestation'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<ManifestationProvider>().createManifestation(
            affirmation: _affirmationController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            category: _selectedCategory,
            targetDate: _targetDate,
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
