import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habit_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/activity_mapping_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/manifestation_provider.dart';
import '../habits/habits_screen.dart';
import '../journal/journal_screen.dart';
import '../activity_mapping/activity_mapping_screen.dart';
import '../expenses/expenses_screen.dart';
import '../manifestation/manifestation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HabitsScreen(),
    JournalScreen(),
    ActivityMappingScreen(),
    ManifestationScreen(),
    ExpensesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final habitProvider = context.read<HabitProvider>();
    final journalProvider = context.read<JournalProvider>();
    final activityProvider = context.read<ActivityMappingProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final manifestationProvider = context.read<ManifestationProvider>();

    await Future.wait([
      habitProvider.loadHabits(),
      journalProvider.loadEntries(),
      activityProvider.loadMappings(),
      expenseProvider.loadAll(),
      manifestationProvider.loadManifestations(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.link_outlined),
            selectedIcon: Icon(Icons.link),
            label: 'Routines',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Manifest',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}
