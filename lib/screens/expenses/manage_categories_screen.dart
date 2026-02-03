import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Categories'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create categories to organize your expenses',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return _buildCategoryTile(context, provider, category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    ExpenseProvider provider,
    ExpenseCategory category,
  ) {
    final categoryExpenses = provider.expensesByCategory[category.id] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color != null
              ? Color(int.parse(category.color!, radix: 16) | 0xFF000000)
                  .withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getCategoryIcon(category.icon),
            color: category.color != null
                ? Color(int.parse(category.color!, radix: 16) | 0xFF000000)
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(category.name),
        subtitle: categoryExpenses > 0
            ? Text('\$${categoryExpenses.toStringAsFixed(2)} this month')
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditCategoryDialog(context, category);
            } else if (value == 'delete') {
              _confirmDeleteCategory(context, category);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'bills':
        return Icons.receipt_long;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'travel':
        return Icons.flight;
      case 'personal':
        return Icons.person;
      default:
        return Icons.category;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryFormDialog(context, null);
  }

  void _showEditCategoryDialog(
      BuildContext context, ExpenseCategory category) {
    _showCategoryFormDialog(context, category);
  }

  void _showCategoryFormDialog(
      BuildContext context, ExpenseCategory? existing) {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    String? selectedIcon = existing?.icon;
    String? selectedColor = existing?.color;

    final icons = [
      'food',
      'transport',
      'shopping',
      'entertainment',
      'health',
      'education',
      'bills',
      'groceries',
      'travel',
      'personal',
    ];

    final colors = [
      'E53935',
      'D81B60',
      '8E24AA',
      '5E35B1',
      '3949AB',
      '1E88E5',
      '00ACC1',
      '00897B',
      '43A047',
      'F4511E',
      'FB8C00',
      '6D4C41',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Edit Category' : 'New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                const Text('Icon'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedIcon = iconName),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getCategoryIcon(iconName), size: 24),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((colorHex) {
                    final isSelected = selectedColor == colorHex;
                    final color =
                        Color(int.parse(colorHex, radix: 16) | 0xFF000000);
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedColor = colorHex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color, blurRadius: 8)]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final provider = context.read<ExpenseProvider>();
                if (existing != null) {
                  await provider.updateCategory(existing.copyWith(
                    name: name,
                    icon: selectedIcon,
                    color: selectedColor,
                  ));
                } else {
                  await provider.createCategory(
                    name: name,
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existing != null ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(
      BuildContext context, ExpenseCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Delete "${category.name}"? All expenses in this category will also be removed.'),
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
              context.read<ExpenseProvider>().deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
