import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan sabit metinler.
///
/// Türkçe karşılıkları tek noktadan değiştirilebilir; locale değişimi
/// (örn. çoklu dil) eklendiğinde bu sınıf l10n çözümüyle değiştirilir.
class AppStrings {
  AppStrings._();

  static const appName = 'Bütçe Takipçisi';

  // BottomNavigationBar sekme isimleri.
  static const tabDashboard = 'Özet';
  static const tabExpenses = 'Harcamalar';
  static const tabBudget = 'Bütçe';

  static const currencySymbol = '₺';

  /// `intl` paketinin tarih/sayı formatları için kullandığı locale.
  /// `initializeDateFormatting` ve `Intl.defaultLocale` ile aynı olmalı.
  static const locale = 'tr_TR';
}

/// Tek bir harcama kategorisinin tipli temsili.
///
/// Kategoriler DB'de string olarak saklanır; bu sınıf renk ve ikon
/// gibi UI bilgilerini taşımak için kullanılır. DB'den gelen string'i
/// [AppCategories.byName] ile [AppCategory]'e çevirebilirsin.
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

/// Sabit kategori listesi. UI dropdown'larında ve renk/ikon
/// eşleşmesinde kullanılır.
///
/// Yeni kategori eklemek istersen [all] listesine ekle yeterli —
/// dropdown'lar ve dashboard otomatik gösterir.
class AppCategories {
  AppCategories._();

  // Her kategori için Material Design'a uygun, kontrastlı bir renk
  // seçildi. Dark mode'da da yeterli okunabilirlik sağlanması için
  // 500-600 ton aralığında tutuldu.
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

  /// Tüm kategorilerin sabit listesi. UI dropdown'ları bunu tüketir.
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

  /// İsme göre kategori bul. DB'den string olarak gelen kategoriyi
  /// UI temsiline çevirmek için. Bilinmeyen isim için "Diğer" döner —
  /// hiçbir senaryoda crash yok.
  static AppCategory byName(String name) {
    return all.firstWhere((c) => c.name == name, orElse: () => diger);
  }
}

/// Parola sıfırlama için kullanılan sabit güvenlik soruları.
///
/// Sayı sınırlı tutuldu (4) — kullanıcı dropdown'da hızlıca seçebilsin.
/// Sorular kullanıcının kolay hatırlayabileceği ama başkalarının
/// tahmin edemeyeceği bilgileri sorar.
class SecurityQuestions {
  SecurityQuestions._();

  static const list = <String>[
    'İlk evcil hayvanınızın adı?',
    'Doğduğunuz şehir?',
    'İlkokul öğretmeninizin adı?',
    'Annenizin kızlık soyadı?',
  ];
}

/// `shared_preferences` anahtarları — typo'ya karşı tek nokta.
class PrefsKeys {
  PrefsKeys._();

  /// Auto-login için saklanan son giriş yapan kullanıcı ID'si.
  static const lastUserId = 'last_user_id';

  /// Kullanıcının tema tercihi: 'light' / 'dark' / 'system'.
  static const themeMode = 'theme_mode';

  /// İlk açılış onboarding ekranı tamamlandı mı?
  static const onboardingSeen = 'onboarding_seen';
}
