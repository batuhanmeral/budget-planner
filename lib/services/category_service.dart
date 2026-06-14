import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../models/custom_category.dart';
import 'custom_category_repository.dart';

class CategoryService extends ChangeNotifier {
  CategoryService._();
  static final instance = CategoryService._();

  static const kindExpense = 'expense';
  static const kindIncome = 'income';

  List<CustomCategory> _custom = const [];

  List<CustomCategory> get customCategories =>
      List.unmodifiable(_custom.where((c) => c.kind == kindExpense));

  List<AppCategory> get all => [
    ...AppCategories.all,
    ..._custom
        .where((c) => c.kind == kindExpense)
        .map((c) => c.toAppCategory()),
  ];

  List<CustomCategory> get customIncomeCategories =>
      List.unmodifiable(_custom.where((c) => c.kind == kindIncome));

  List<AppCategory> get incomeAll => [
    ...IncomeSources.all,
    ..._custom.where((c) => c.kind == kindIncome).map((c) => c.toAppCategory()),
  ];

  Future<void> loadForUser(int userId) async {
    _custom = await CustomCategoryRepository.instance.getAllForUser(userId);
    notifyListeners();
  }

  void clear() {
    if (_custom.isEmpty) return;
    _custom = const [];
    notifyListeners();
  }

  AppCategory byName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => AppCategories.diger,
    );
  }

  AppCategory incomeByName(String name) {
    return incomeAll.firstWhere(
      (c) => c.name == name,
      orElse: () => IncomeSources.diger,
    );
  }

  Future<void> addCustom({
    required int userId,
    required String name,
    required IconData icon,
    required Color color,
    String kind = kindExpense,
  }) async {
    final cc = CustomCategory(
      userId: userId,
      name: name.trim(),
      iconCode: icon.codePoint,
      colorInt: color.toARGB32(),
      kind: kind,
    );
    await CustomCategoryRepository.instance.insert(cc);
    await loadForUser(userId);
  }

  Future<void> deleteCustom({required int id, required int userId}) async {
    await CustomCategoryRepository.instance.delete(id: id, userId: userId);
    await loadForUser(userId);
  }

  Future<bool> nameExists({
    required int userId,
    required String name,
    String kind = kindExpense,
  }) {
    return CustomCategoryRepository.instance.existsByName(
      userId: userId,
      name: name.trim(),
      kind: kind,
    );
  }
}

class CategoryIcons {
  CategoryIcons._();

  static const list = <IconData>[
    Icons.coffee,
    Icons.local_cafe,
    Icons.cake,
    Icons.local_bar,
    Icons.restaurant_menu,
    Icons.local_pizza,
    Icons.icecream,
    Icons.shopping_bag,
    Icons.local_mall,
    Icons.local_grocery_store,
    Icons.devices,
    Icons.smartphone,
    Icons.computer,
    Icons.headphones,
    Icons.book,
    Icons.menu_book,
    Icons.flight,
    Icons.directions_car,
    Icons.train,
    Icons.local_gas_station,
    Icons.home,
    Icons.bed,
    Icons.work,
    Icons.business_center,
    Icons.medical_services,
    Icons.fitness_center,
    Icons.sports_esports,
    Icons.spa,
    Icons.pets,
    Icons.child_care,
    Icons.local_florist,
    Icons.celebration,
    Icons.card_giftcard,
    Icons.savings,
    Icons.attach_money,
    Icons.credit_card,
  ];
}

class CategoryColors {
  CategoryColors._();

  static const list = <Color>[
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFFEAB308),
    Color(0xFF84CC16),
    Color(0xFF22C55E),
    Color(0xFF10B981),
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
    Color(0xFFD946EF),
    Color(0xFFEC4899),
    Color(0xFF6B7280),
  ];
}
