import 'package:flutter/material.dart';

import '../../app/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = <String>[
    AppStrings.tabDashboard,
    AppStrings.tabExpenses,
    AppStrings.tabBudget,
  ];

  static const _placeholders = <Widget>[
    _PlaceholderPage(
      icon: Icons.pie_chart_outline,
      label: 'Özet ekranı Faz 8\'de gelecek.',
    ),
    _PlaceholderPage(
      icon: Icons.list_alt,
      label: 'Harcamalar ekranı Faz 6\'da gelecek.',
    ),
    _PlaceholderPage(
      icon: Icons.savings_outlined,
      label: 'Bütçe ekranı Faz 7\'de gelecek.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: _placeholders[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: AppStrings.tabDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: AppStrings.tabExpenses,
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: AppStrings.tabBudget,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
