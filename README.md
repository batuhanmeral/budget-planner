# Balancio

> An offline-first, multi-user personal finance app for tracking expenses, income, and monthly budgets — built with Flutter and SQLite, with hand-drawn charts and full TR/EN localization.

Balancio is a **personal finance app** that helps you record where your money goes and comes from, set monthly budget limits, and understand your habits at a glance. Every account keeps its own private data on the device, passwords are hashed, and the whole app works without an internet connection. There is no third-party backend and no state-management library — just clean Flutter and SQLite.

## 🚀 Features

- **Track everything**: expenses and incomes with categories, sources, notes, and dates — full add, edit, delete, and detail views for both.
- **Browse your way**: debounced note search, category/source filters, date ranges (this week / this month / custom), flexible sorting, and a month calendar view.
- **Bulk actions**: long-press an expense to multi-select, then batch delete or change the category of many records at once.
- **Recurring transactions**: monthly templates for both expenses and incomes, managed from a single two-tab screen — with automatic backfill that fills every missed month when you create a past-dated entry.
- **Budgets**: per-category monthly limits with a friendly amber warning at 90% and a red alert once exceeded.
- **Insightful dashboard**: a net-balance card, category breakdown for expenses or income (weekly / monthly / yearly), a last-six-months summary with per-month detail, a seven-day spending chart, and recent activity — every chart is hand-drawn with `CustomPainter`, no chart library involved.
- **Accounts & security**: registration with a security question, salt + SHA-256 password hashing, brute-force lockout after repeated failures, password recovery, and account deletion that cascades all related data.
- **Personal profile**: set an avatar photo from the camera or gallery, and edit your username and full name.
- **Offline-first & multi-user**: everything lives in a local SQLite database, and every query is scoped so each user only ever sees their own data.
- **Themes & languages**: light / dark / system theme with a background-matched navigation bar, instant Turkish ↔ English switching, and currency selection — all remembered across launches.

## 🛠️ Tech Stack

| Layer | Technologies |
| --- | --- |
| **Language & SDK** | Dart (≥ 3.11), Flutter (stable channel) |
| **UI** | Material 3, `StatefulWidget` + `setState` (no state-management package), custom `CustomPainter` charts |
| **Persistence** | SQLite via `sqflite`, `shared_preferences` for preferences, `path` / `path_provider` |
| **Security** | `crypto` (per-user 16-byte salt + SHA-256), `PRAGMA foreign_keys = ON`, per-user data isolation |
| **Localization & Format** | `flutter_localizations`, `intl` (TR/EN strings, currency, dates) |
| **Media** | `image_picker` (profile avatar capture/selection) |
| **Tooling / Testing** | `flutter_lints`, `flutter_test`, `sqflite_common_ffi` (in-memory DB tests) |

## 📦 Installation

### Prerequisites

- Flutter SDK on the **stable** channel (Dart ≥ 3.11)
- Android Studio or Xcode, plus a connected device or emulator/simulator

### 1. Clone & install

```bash
git clone https://github.com/batuhanmeral/Balancio.git
cd Balancio
flutter pub get
```

### 2. Run

```bash
flutter run                # run on the selected device/emulator
flutter run -d <deviceId>  # target a specific device (see: flutter devices)
```

### 3. Build a release

```bash
flutter build apk          # Android
flutter build ios          # iOS (requires a configured signing profile)
```

> Target platforms are **Android** and **iOS**. Avatar capture needs camera/photo permissions, which are already declared for both platforms.

## 💡 Usage

### First launch

A three-page onboarding introduces the app the first time it runs (shown only once). After that you register with your **full name, username, password, and a security question** — the security answer is what lets you recover your password later. From then on, auto-login remembers your session.

### Project structure

```
lib/
├── app/         # theme, routes, constants, theme & locale & currency controllers
├── l10n/        # AppL10n abstract base + Turkish + English implementations
├── models/      # User, Expense, Income, Budget, CustomCategory, RecurringExpense/Income
├── services/    # DatabaseService, AuthService, password hasher, repositories,
│                # CategoryService, recurring runners (with backfill)
├── screens/     # auth/, home/, dashboard/, expenses/, income/, budget/,
│                # recurring/, settings/, onboarding/
├── widgets/     # shared UI: chips, tiles, charts, banners, dialogs
└── utils/       # validators, formatters, date/money utils, Turkish-safe normalize
```

### Development

```bash
flutter analyze     # static analysis (expected: no issues)
flutter test        # unit & widget tests (in-memory SQLite via FFI)
```

### Data isolation

Every query is filtered with `WHERE user_id = ?`, deleting an account removes all of its data through `ON DELETE CASCADE`, and foreign keys are enforced on each connection. The schema evolves through versioned migrations so existing data is never lost between releases.

## 📸 Screenshots

| Dashboard | Charts & Insights | Expenses |
| :---: | :---: | :---: |
| ![Dashboard](docs/Screenshot_1.jpg) | ![Charts](docs/Screenshot_2.jpg) | ![Expenses](docs/Screenshot_3.jpg) |

## 📄 License

Released under the MIT License. © 2026 Batuhan Meral. Built as a Mobile Application Development course project.
