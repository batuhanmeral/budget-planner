import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../models/custom_category.dart';
import 'custom_category_repository.dart';

/// Sabit ve özel kategorileri tek bir noktadan sunan servis.
///
/// Sorun: UI'da bir [Expense] gösterirken kategori adından renk/ikon
/// gerekiyor. Sabit kategoriler [AppCategories]'tedir; özel kategoriler
/// DB'de. Her render'da DB sorgusu yapmak verimsiz olur — bu servis
/// kullanıcının özel kategorilerini bir kez yükler ve bellekte tutar.
///
/// [ChangeNotifier] olduğu için CRUD sonrası dinleyiciler (örn. picker
/// ekranı, dropdown'lı formlar) otomatik yenilenir.
class CategoryService extends ChangeNotifier {
  CategoryService._();
  static final instance = CategoryService._();

  List<CustomCategory> _custom = const [];

  /// Aktif kullanıcının özel kategorileri (salt-okunur).
  List<CustomCategory> get customCategories => List.unmodifiable(_custom);

  /// Sabit + özel kategorilerin birleşik listesi. Dropdown'larda ve
  /// filtre satırlarında kullanılır.
  List<AppCategory> get all => [
    ...AppCategories.all,
    ..._custom.map((c) => c.toAppCategory()),
  ];

  /// Sadece özel kategoriler [AppCategory] olarak — UI'da ayrım yapmak
  /// gerekirse.
  List<AppCategory> get customAsAppCategories =>
      _custom.map((c) => c.toAppCategory()).toList();

  /// Aktif kullanıcının kategorilerini DB'den yükler. Login + register +
  /// auto-login sonrası AuthService tarafından çağrılır.
  Future<void> loadForUser(int userId) async {
    _custom = await CustomCategoryRepository.instance.getAllForUser(userId);
    notifyListeners();
  }

  /// Logout sonrası belleği temizler — bir sonraki kullanıcı eskiyi görmez.
  void clear() {
    if (_custom.isEmpty) return;
    _custom = const [];
    notifyListeners();
  }

  /// Kategori adından [AppCategory] döner. Hem sabit hem özel listede
  /// arar. Bulamazsa varsayılan olarak "Diğer" döner — UI kırılmaz.
  AppCategory byName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => AppCategories.diger,
    );
  }

  /// Yeni özel kategori ekler. Çakışma kontrolü repository'de UNIQUE
  /// kısıtıyla yapılır; UI tarafı önce [nameExists] ile sormalı.
  Future<void> addCustom({
    required int userId,
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final cc = CustomCategory(
      userId: userId,
      name: name.trim(),
      iconCode: icon.codePoint,
      colorInt: color.toARGB32(),
    );
    await CustomCategoryRepository.instance.insert(cc);
    await loadForUser(userId);
  }

  /// Özel kategori siler. Bu kategoriye sahip mevcut harcamalar etkilenmez
  /// — string olarak "Diğer" gibi davranır (byName fallback).
  Future<void> deleteCustom({required int id, required int userId}) async {
    await CustomCategoryRepository.instance.delete(id: id, userId: userId);
    await loadForUser(userId);
  }

  /// Form'da çakışma uyarısı için.
  Future<bool> nameExists({required int userId, required String name}) {
    return CustomCategoryRepository.instance.existsByName(
      userId: userId,
      name: name.trim(),
    );
  }
}

/// Kategori formunda kullanıcının seçebileceği sabit Material Icons listesi.
///
/// **Önemli:** Bu liste statik referans olarak burada tutulur ki Flutter
/// release modunda icon tree-shaking devreye girince glyph'ler font'tan
/// silinmesin. Kullanıcı bu listedekiler dışında ikon seçemez.
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

/// Kategori formunda kullanıcının seçebileceği sabit renk paleti.
class CategoryColors {
  CategoryColors._();

  static const list = <Color>[
    Color(0xFFEF4444), // kırmızı
    Color(0xFFF97316), // turuncu
    Color(0xFFF59E0B), // amber
    Color(0xFFEAB308), // sarı
    Color(0xFF84CC16), // lime
    Color(0xFF22C55E), // yeşil
    Color(0xFF10B981), // zümrüt
    Color(0xFF14B8A6), // teal
    Color(0xFF06B6D4), // cyan
    Color(0xFF3B82F6), // mavi
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFA855F7), // mor
    Color(0xFFD946EF), // füşya
    Color(0xFFEC4899), // pembe
    Color(0xFF6B7280), // gri
  ];
}
