# MusikaKhula 

**Empowering Women Businesswomen in Zimbabwe - Record. Track. Grow. Unlock Loans.**

A mobile-first fintech platform for informal market traders in Zimbabwe. MusikaKhula enables traders to record daily sales, track inventory, and build a **Financial Health Score** (a data-driven credit proxy on the 300-850 scale) that can unlock access to micro-loans from partner financial institutions.

Built with Flutter + SQLite (offline-first) + Supabase (cloud sync).

---

## Project Status

| Phase | Name | Status |
|-|-|-|
| **Phase 0** | Environment & Foundation | **COMPLETE** |
| Phase 1 | Core Screens | In Progress |
| Phase 2 | Reports & Analytics | Planned |
| Phase 3 | Authentication & Cloud Sync | Planned |
| Phase 4 | Intelligent Features | Planned |
| Phase 5 | Production & Polish | Planned |

---

## What MusikaKhula Does

Informal traders at markets like **Mbare Musika (Harare)**, **Bulawayo City Centre**, and **Sakubva (Mutare)** have no formal income records, no bank statements, and no credit history, making them invisible to traditional microfinance institutions.

MusikaKhula fixes this by:

- **Recording every sale** locally on the trader's phone (no internet required)
- **Tracking inventory** and automatically reducing stock when a sale is recorded
- **Computing a Financial Health Score** from six behavioural signals (Sales Consistency, Revenue Stability, Restock Velocity, Savings Behaviour, Transaction Volume Growth, Multi-Currency Handling)
- **Syncing to Supabase** when connectivity is available, building a verifiable transaction history
- **Surfacing micro-loan offers** to traders whose **Financial Health System** (FHS) meets the qualification threshold

---

## Zimbabwean Context

| Feature | Why it matters |
|-|-|
| **Offline-first** | Informal markets have unreliable mobile data |
| **English / Shona / Ndebele** | Three languages for the three major language groups |
| **USD / ZiG / ZAR** | Zimbabwe's multi-currency cash economy |
| **EcoCash / OneMoney** | Dominant mobile money platforms |
| **PIN-based login** | No email required, uses phone number + 4-digit PIN |

---

## Tech Stack

| Layer | Technology | Purpose |
|-|-|-|
| Mobile | Flutter 3.44.8 (Dart) | Cross-platform Android app |
| Local DB | SQLite (sqflite) | Offline-first data storage |
| Cloud DB | Supabase (PostgreSQL) | Cloud sync + authentication |
| Charts | fl_chart | Business reports visualisation |
| Research | R / tidymodels | Credit scoring model |
| Backend | FastAPI (Python) | Phase 3+ API server |
| Version Control | Git / GitHub | Full history from day one |

---

## Repository Structure


```
MusikaKhula/
|- mobile_app/          <- Flutter project (Phases 0-5)
|   |- lib/
|   |   |- models/      <- Data structures (Sale, InventoryItem)
|   |   |- services/    <- Database layer (DatabaseHelper)
|   |   |- screens/     <- 18 UI screens
|   |   |- widgets/     <- Reusable UI components
|   |   |- main.dart    <- App entry point
|   |- pubspec.yaml     <- Package dependencies
|- backend/             <- FastAPI Python server (Phase 3+)
|- r_research/          <- Credit scoring R scripts 
|- docs/                <- Project documentation
```

---

## Phase 0 : What Was Built

Phase 0 establishes the **complete data foundation** that every screen in the app reads from and writes to.

### Development Environment

| Tool | Version | Notes  |
|-|-|-|
| Flutter SDK | 3.44.8 stable | Installed via git clone snap unavailable on Linux Mint |
| Android Studio | Quail 2 \| 2026.1.2 | Flatpak install ( required manual Dart SDK path config) |
| Android SDK | 36.1.0 | Includes ADB, emulator, platform-tools |
| Dart | Bundled with Flutter | Autocomplete configured in Android Studio |
| Linux Mint | 21.3 (64-bit) | Dell Latitude 5410 |

**`flutter doctor` result: No issues found  (all 6 checks green)

---

### Data Models

#### `lib/models/sale.dart`
Defines what a single sale looks like and how it moves between the app and SQLite.

**Key design decisions:**
- `costPrice` stored separately so profit can be computed (revenue alone is not enough for FHS)
- `isSynced` implements the offline queue (sales recorded offline are uploaded when connectivity returns)
- `toMap()` / `fromMap()` handle conversion to/from SQLite row format

---

#### `lib/models/inventory_item.dart`
Defines a stock-keeping unit with a **per-item threshold** for stock status.
- This getter computes status relative to each item's own `lowStockThreshold`.

---

### Database Layer

#### `lib/services/database_helper.dart`

A **singleton** SQLite service (only one database connection ever exists). Implemented using the `sqflite` package with `sqflite_common_ffi` for Linux desktop support during development.

---

### Offline-First Architecture

Every sale is saved locally first (no internet required).

```
Record Sale -> SQLite (is_synced = 0) -> internet detected -> upload to Supabase -> mark is_synced = 1
```

If upload fails, the record stays at `is_synced = 0` and retries automatically next time.

---

### App Shell

`main.dart` sets up:
- MusikaKhula teal theme (`#0F6E56 a.k.a MM_Green`)
- Bottom navigation bar (Home / Analysis / Stock Track / More)
- Placeholder screens for all four tabs

**Emulator:** Pixel 7 AVD (app running in debug mode)

---

## Setup Challenges Resolved

| # | Problem | Resolution |
|-|-|-|
| 1 | `snap: command not found` | Manual git clone install of Flutter |
| 2 | CMake clang++ missing | `sudo apt-get install clang cmake ninja-build...` |
| 3 | `adb: command not found` | Added `ANDROID_HOME/platform-tools` to PATH |
| 4 | `emulator -list-avds` empty | Flatpak stores AVDs in non-standard path |
| 5 | AVD not found | Set `ANDROID_AVD_HOME` to Flatpak config path |


---

## How to Run (Development)

### Prerequisites
- Linux Mint 21.3 (or Ubuntu-based)
- Flutter 3.44.8 stable installed at `~/flutter`
- Android Studio with Flutter plugin
- Pixel 7 AVD created in Android Studio

### Environment variables (`~/.bashrc`)
```bash
export PATH="$PATH:$HOME/flutter/bin"
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
export ANDROID_AVD_HOME="$HOME/.var/app/com.google.AndroidStudio/config/.android/avd"
```

### Run the app
```bash
# 1. Launch the emulator
emulator -avd Pixel_7 &

# 2. Wait for Android to boot (~30 seconds), then:
cd ~/MusikaKhula/mobile_app
flutter run

```

---

##  Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  sqflite_common_ffi: current
  path: ^1.9.0
  path_provider: ^2.1.3
  supabase_flutter: ^2.5.6
  cupertino_icons: ^1.0.8
```

---

## All 18 Screens

| Screen | File | Phase |
|-|-|-|
| Language Select | `language_select_screen.dart` | 3 |
| Login | `login_screen.dart` | 3 |
| Register | `register_screen.dart` | 3 |
| **Home** | `home_screen.dart` | **1 (next)** |
| Analysis | `analysis_screen.dart` | 2 |
| **Stock Track** | `stock_track_screen.dart` | **1 (next)** |
| More | `more_screen.dart` | 1 |
| **Record Sale** | `record_sale_screen.dart` | **1 (next)** |
| AI Forecast | `ai_forecast_screen.dart` | 4 |
| Currency Settings | `currency_settings_screen.dart` | 5 |
| Mobile Money Sync | `mobile_money_screen.dart` | 4 |
| Savings Goals | `savings_goals_screen.dart` | 2 |
| Loans | `loans_screen.dart` | 4 |
| Notifications | `notifications_screen.dart` | 5 |
| Financial Health | `financial_health_screen.dart` | 2 |
| Data Sync Status | `data_sync_screen.dart` | 3 |
| Support Chat | `support_chat_screen.dart` | 5 |
| Backup & Restore | `backup_screen.dart` | 5 |

---

## Documentation

- Will be provided when system completes
---

## Developer

**Dean** : BSc Honours Informatics, Year 2  
National University of Science & Technology (NUST), Bulawayo, Zimbabwe

---

## Process Model

This project follows the **Evolutionary Development** model as defined in:

- Sommerville, I. (2007). *Software Engineering*, 8th Edition. Pearson Education.

Each phase produces a testable, functional increment of the system.

---

*MusikaKhula - Empowering Zimbabwe's informal economy, one sale at a time.*
