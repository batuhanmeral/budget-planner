# Bütçe Takipçisi

Günlük harcamalarınızı ve aylık bütçe hedeflerinizi takip etmenize yardımcı olan, **Dart + Flutter + SQLite** ile geliştirilmiş mobil uygulama. Çoklu kullanıcı destekli; parolalar hash'lenerek saklanır ve her kullanıcı yalnızca kendi verilerine erişir.

> Üniversite ders projesi olarak müfredat kapsamında geliştirildi: yalnızca standart Flutter yapıları (`StatefulWidget` + `setState`), `sqflite`, `crypto`, `shared_preferences`, `intl`, `flutter_localizations`. Ek state-management veya backend paketi kullanılmaz.

---

## Özellikler

- **Kimlik doğrulama:** Kayıt, giriş, otomatik giriş (oturum hatırlama), parola değiştirme, hesap silme.
- **Parola güvenliği:** Kullanıcı başına rastgele 16 byte salt + SHA-256 hash. 5 başarısız denemede 30 saniyelik hesap kilidi.
- **Parolamı unuttum:** Kayıtta seçilen güvenlik sorusu üzerinden parola sıfırlama.
- **Harcama CRUD:** Kategori, tutar, tarih, açıklama; arama, tarih aralığı filtresi, sıralama, kategori filtreleri.
- **Bütçe CRUD:** Kategori başına aylık limit; %90 sarı / %100 kırmızı uyarı.
- **Dashboard:** Bu ay toplam, geçen aya göre karşılaştırma, son 7 gün bar grafik, kategori dağılımı, son 5 harcama, bütçe uyarı banner'ı.
- **Tema:** Aydınlık / Karanlık / Sistem (kalıcı).
- **Türkçe arayüz** + tarih/sayı formatları.
- **Veri izolasyonu:** Tüm sorgular `WHERE user_id = ?` ile filtrelenir; hesap silme cascade ile tüm verileri kaldırır.

---

## Klasör Yapısı

```
lib/
├── app/         # tema, route'lar, sabitler, theme controller
├── models/      # User, Expense, Budget
├── services/    # DatabaseService, AuthService, password hasher, repository'ler
├── screens/     # auth/, home/, dashboard/, expenses/, budget/, settings/
├── widgets/     # paylaşılan UI bileşenleri
└── utils/       # validators, formatters, date_utils, money_utils, string_utils
```

---

## Kurulum

```bash
flutter pub get
flutter run
```

Hedef platformlar: **Android & iOS**.

---

## Geliştirme

```bash
flutter analyze      # statik analiz
flutter test         # birim testler
dart format .        # kod biçimleme
```

---

## Veritabanı Şeması

- `users(id, username, password_hash, salt, security_question, security_answer_hash, failed_attempts, lockout_until, created_at)`
- `expenses(id, user_id, amount, category, date, note, created_at)` — `ON DELETE CASCADE`
- `budgets(id, user_id, category, monthly_limit, updated_at)` — `UNIQUE(user_id, category)`, `ON DELETE CASCADE`

Foreign key zorlaması her bağlantıda `PRAGMA foreign_keys = ON` ile etkinleştirilir.

---

## Lisans

Üniversite ders projesi.
