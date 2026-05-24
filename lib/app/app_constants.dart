import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  static const appName = 'Bütçe Takipçisi';

  static const tabDashboard = 'Özet';
  static const tabExpenses = 'Harcamalar';
  static const tabBudget = 'Bütçe';

  static const currencySymbol = '₺';
  static const locale = 'tr_TR';
}

class AppCategory {
  final String name;
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppCategories {
  AppCategories._();

  static const yemek = AppCategory(
    name: 'Yemek',
    icon: Icons.restaurant,
    color: Color(0xFFF97316),
  );
  static const ulasim = AppCategory(
    name: 'Ulaşım',
    icon: Icons.directions_bus,
    color: Color(0xFF3B82F6),
  );
  static const market = AppCategory(
    name: 'Market',
    icon: Icons.shopping_cart,
    color: Color(0xFF22C55E),
  );
  static const fatura = AppCategory(
    name: 'Fatura',
    icon: Icons.receipt_long,
    color: Color(0xFFEF4444),
  );
  static const eglence = AppCategory(
    name: 'Eğlence',
    icon: Icons.movie,
    color: Color(0xFFA855F7),
  );
  static const saglik = AppCategory(
    name: 'Sağlık',
    icon: Icons.healing,
    color: Color(0xFFEC4899),
  );
  static const egitim = AppCategory(
    name: 'Eğitim',
    icon: Icons.school,
    color: Color(0xFF6366F1),
  );
  static const diger = AppCategory(
    name: 'Diğer',
    icon: Icons.more_horiz,
    color: Color(0xFF6B7280),
  );

  static const all = <AppCategory>[
    yemek,
    ulasim,
    market,
    fatura,
    eglence,
    saglik,
    egitim,
    diger,
  ];

  static AppCategory byName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => diger,
    );
  }
}

class SecurityQuestions {
  SecurityQuestions._();

  static const list = <String>[
    'İlk evcil hayvanınızın adı?',
    'Doğduğunuz şehir?',
    'İlkokul öğretmeninizin adı?',
    'Annenizin kızlık soyadı?',
  ];
}

class PrefsKeys {
  PrefsKeys._();

  static const lastUserId = 'last_user_id';
  static const themeMode = 'theme_mode';
}
