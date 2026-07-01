# 🏎️ PitStop — Car Service Tracker

> Keep your cars pit-stop ready. Track every service, cost, and reminder — all offline, all on your device.

![Flutter](https://img.shields.io/badge/Flutter-3.16-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.2-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![License](https://img.shields.io/badge/License-MIT-orange)

---

## Features

### 🚗 Car Profiles
- Add multiple vehicles with photo, make/model/year, license plate and current mileage
- All data stored locally — no account, no cloud, no tracking

### 🔧 Service Records
- Log every maintenance event: oil change, tires, brakes, inspection and more
- Attach **photos** (odometer, damage) and **PDF invoices** directly to each record
- Track cost, workshop name, mileage at time of service
- Mileage auto-updates the car's current reading when a higher value is entered

### 🔔 Reminders
- Set reminders by **date** (e.g. next inspection on 15 Mar 2025) and/or **mileage** (e.g. oil change at 150,000 km)
- Visual urgency: **red** = overdue, **amber** = due within 30 days / 1,000 km, **green** = upcoming
- Mark done with a single tap — reminder disappears from active list

### 📊 Cost Statistics
- Total spend per car, average cost per service, date of last service
- Cost breakdown by service type (oil, tires, brakes…) shown as proportional bars
- All numbers calculated locally from your service history

### 🌙 Dark Mode
- Full Material Design 3 with automatic dark/light theme following system setting
- Orange accent `#F97316` throughout for that motorsport feel

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.16 + Material Design 3 |
| State | Riverpod 2.4 (StreamProvider) |
| Navigation | go_router 13 |
| Database | Drift 2.14 (SQLite ORM, offline) |
| SQLite driver | sqlite3_flutter_libs 0.5 |
| Images | image_picker 1.0 |
| Files / PDFs | file_picker 6.2 + open_file 3.3 |
| Localisation | flutter_localizations (Polish 🇵🇱) |

All data stays on-device. No internet permission is requested.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, locale init
├── app.dart                     # MaterialApp + go_router routes
├── core/
│   ├── theme/app_theme.dart     # Material 3 theme, orange seed
│   └── utils/file_helper.dart   # Copy / delete local files
├── data/
│   ├── database/
│   │   ├── tables.dart          # Drift table definitions
│   │   ├── app_database.dart    # DB setup, migrations, FK pragma
│   │   └── app_database.g.dart  # Generated code (drift_dev)
│   └── repositories/
│       ├── vehicle_repository.dart
│       ├── service_repository.dart
│       └── reminder_repository.dart
├── features/
│   ├── vehicles/                # Home screen, car profile, add/edit car
│   ├── services/                # Add/edit service, service detail
│   ├── reminders/               # Add/edit reminder
│   └── stats/                   # Cost statistics screen
└── shared/
    └── widgets/
        ├── service_type_chip.dart   # ServiceType enum + chip
        └── empty_state.dart         # Reusable empty state widget
```

### Database Schema

```
vehicles          — id, name, make, model, year, licensePlate?, photoPath?, currentMileage, createdAt
service_records   — id, vehicleId→vehicles, title, description?, serviceDate, mileage?, cost?, serviceType, workshop?, createdAt
attachments       — id, serviceRecordId→service_records, filePath, fileType (IMAGE|PDF), fileName, createdAt
reminders         — id, vehicleId→vehicles, title, note?, dueDate?, dueMileage?, isDone, serviceType, createdAt
```

Foreign keys with `CASCADE DELETE` ensure no orphaned rows.  
`PRAGMA foreign_keys = ON` is set in Drift's `beforeOpen`.

---

## Getting Started

### Prerequisites

- [Flutter 3.16+](https://docs.flutter.dev/get-started/install)
- Android SDK (API 21+) or Xcode 14+

### Run

```bash
# Clone
git clone https://github.com/marcincyber/pitstop.git
cd pitstop

# Install dependencies
flutter pub get

# Generate Drift code (required after schema changes)
dart run build_runner build --delete-conflicting-outputs

# Generate launcher icons
dart run flutter_launcher_icons

# Run
flutter run
```

### Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture

MVVM-style with Riverpod as the reactive glue:

```
Screen (ConsumerWidget)
  └── watches StreamProvider / Provider
        └── Repository
              └── Drift DAO (generated)
                    └── SQLite (on-device)
```

- Screens subscribe to `StreamProvider` — UI rebuilds automatically when data changes
- Repositories expose typed streams and handle file I/O alongside DB writes
- No use-case layer — repositories are called directly from providers (pragmatic for a personal app)

---

## Supported Platforms

| Platform | Status |
|----------|--------|
| Android (API 21+, Android 5.0) | ✅ Tested |
| iOS (14+) | ✅ Configured |

Tested on: Xiaomi Redmi K30 Pro running crDROID (Android 16).

---

## License

MIT — see [LICENSE](LICENSE) for details.
