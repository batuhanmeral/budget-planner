# Bütçe Takipçisi · Budget Planner

Günlük harcamalarınızı ve aylık bütçe hedeflerinizi takip etmenize yardımcı olan, **Dart + Flutter + SQLite** ile geliştirilmiş çoklu kullanıcı destekli mobil uygulama. Parolalar hash'lenerek saklanır; her kullanıcı yalnızca kendi verisine erişir.

> Üniversite ders projesi olarak müfredat kapsamında geliştirildi. Yalnızca standart Flutter yapıları (`StatefulWidget` + `setState`), `sqflite`, `crypto`, `shared_preferences`, `intl` ve `flutter_localizations` kullanılır. Ek state-management veya backend paketi içermez.

---

## Özellikler

### Kimlik Doğrulama & Güvenlik
- Kayıt, giriş, çıkış, otomatik giriş (oturum hatırlama)
- **Salt + SHA-256** parola hash'leme (her kullanıcıya özel 16 byte salt)
- **Brute-force koruma:** 5 başarısız denemede 30 sn hesap kilidi
- **Güvenlik sorusu ile parola sıfırlama**
- Parola değiştirme, hesap silme (cascade ile tüm veri temizliği)

### Harcama Yönetimi
- CRUD: ekle, düzenle, sil, detay görüntüle
- **Arama** (açıklamada, debounce'lu)
- **Filtreleme** (kategori + tarih aralığı: Bu Hafta / Bu Ay / Özel)
- **Sıralama** (tarih / tutar / kategori, asc/desc)
- **Toplu seçim** (uzun bas → çoklu sil + kategori değiştir)
- **Takvim görünümü** (ay grid + gün bottom sheet)
- Tekrarlayan harcamalar (her ay otomatik insert)

### Bütçe
- Kategori başına aylık limit
- **%90 turuncu / %100 kırmızı** uyarı banner'ı
- Görsel doluluk göstergesi

### Dashboard
- Greeting + bu ay toplam + geçen aya göre %değişim
- **Pasta grafiği** (CustomPainter, interaktif dilim seçimi)
- **Haftalık bar grafiği** (son 7 gün)
- **Yıllık özet** (12 aylık bar grafik + yıl seçici)
- **Hızlı Ekle** (en sık kullanılan kategoriler için tek dokunuş)
- Son 5 harcama (detaya tıklanabilir)
- Bütçe uyarı banner'ı

### Özelleştirme
- **Özel kategoriler** (36 ikon + 16 renk palet)
- **Tema:** Aydınlık / Karanlık / Sistem (kalıcı)
- **Çoklu dil:** Türkçe / English (kalıcı)
- Türkçe yerel para birimi / tarih formatları

### İlk Açılış
- 3 sayfalık onboarding (görsel tanıtım)

### Veri İzolasyonu
Tüm sorgular `WHERE user_id = ?` ile filtrelenir. Hesap silme cascade ile tüm verileri kaldırır. Foreign key zorlaması her bağlantıda `PRAGMA foreign_keys = ON` ile etkin.

---

## Klasör Yapısı

```
lib/
├── app/         # tema, route'lar, sabitler, theme & locale controller
├── l10n/        # AppL10n abstract + tr + en
├── models/      # User, Expense, Budget, CustomCategory, RecurringExpense
├── services/    # DatabaseService, AuthService, password hasher,
│                # repository'ler, CategoryService, RecurringExpenseRunner
├── screens/     # auth/, home/, dashboard/, expenses/, budget/,
│                # settings/, recurring/, onboarding/
├── widgets/     # paylaşılan UI bileşenleri (chip, tile, chart, banner...)
└── utils/       # validators, formatters, date_utils, money_utils,
                 # string_utils (Türkçe-güvenli normalize)
```

---

## Kurulum

```bash
flutter pub get
flutter run
```

Hedef platformlar: **Android & iOS**.

İlk açılışta onboarding ekranı görüntülenir. Sonrasında kayıt olup uygulamayı kullanmaya başlayabilirsin.

---

## Geliştirme

```bash
flutter analyze      # statik analiz (uyarı olmamalı)
flutter test         # birim testler (29 test, hepsi yeşil)
dart format .        # kod biçimleme
```

---

## Veritabanı Şeması (v2)

```
users(
  id, username (UNIQUE, NOCASE), password_hash, salt,
  security_question, security_answer_hash,
  failed_attempts, lockout_until, created_at
)

expenses(
  id, user_id (FK → users, CASCADE),
  amount, category, date (YYYY-MM-DD), note, created_at
)

budgets(
  id, user_id (FK), category, monthly_limit, updated_at,
  UNIQUE(user_id, category)
)

custom_categories(
  id, user_id (FK), name, icon_code, color_int, created_at,
  UNIQUE(user_id, name)
)

recurring_expenses(
  id, user_id (FK), amount, category, note,
  day_of_month (1-31), last_inserted_year_month,
  active, created_at
)
```

Tüm zaman damgaları UTC. Foreign key zorlaması her bağlantıda
`PRAGMA foreign_keys = ON` ile etkinleştirilir. Migration `onUpgrade`
ile yapılır (v1 → v2).

---

## Mimari Kararlar

- **State yönetimi:** Yalnızca `setState` + Flutter SDK'sındaki `ChangeNotifier`
- **Lokalizasyon:** Elle yazılmış `AppL10n` abstract sınıfı + TR/EN implementations (ARB codegen kullanılmadı)
- **Para tipi:** REAL (double), her hesapta `roundMoney` ile 2 ondalığa yuvarlanır
- **Türkçe metin karşılaştırma:** `normalizeIdentifier` (İ/I/Ş/Ğ/Ü/Ö/Ç → ASCII)
- **Kategori adları:** DB'de string saklandığı için lokalize edilmedi (kullanıcı verisi tutarlılığı)

Detaylar için `.docs/ARCHITECTURE.md`.

---

## Lisans

Üniversite ders projesi.
