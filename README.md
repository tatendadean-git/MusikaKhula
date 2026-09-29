# MusikaKhula 

**Empowering Businesswomen in Zimbabwe - Record. Track. Grow. Unlock Loans.**

A mobile-first fintech platform for informal market traders in Zimbabwe (e.g., Mbare Musika, Bulawayo City Centre, Makokoba, Sakubva). MusikaKhula enables traders to record daily sales with auto-fill inventory lookups, track real-time stock levels with color-coded status badges, manage credit sales (Chikwereti), and build a verifiable **Financial Health Score** (FHS) that can unlock access to micro-loans from partner financial institutions.

Built with Flutter + SQLite (offline-first architecture).

---

## Project Status

| Phase | Name | Status |
|-|-|-|
| **Phase 0** | Environment & Foundation | **COMPLETE** |
| **Phase 1** | Core Screens & Business Logic | **COMPLETE** |
| Phase 2 | Reports & Analytics | Planned |
| Phase 3 | Authentication & Cloud Sync | Planned |
| Phase 4 | Intelligent Features | Planned |
| Phase 5 | Production & Polish | Planned |

---

## Phase 1 Implemented Features

### 1. Core Screens (`home_screen.dart`, `analysis_screen.dart`, `stock_track_screen.dart`, `more_screen.dart`, `record_sale_screen.dart`)
- **Home Screen**: 
  - Offline Mode active indicator banner.
  - Gradient profit card displaying aggregated profits and financial status.
  - Credit health card (`Fair` / score `591`).
  - Services grid (Sale, Forecast, Currency, M-Money, Savings, Loans, Alerts).
  - Summary cards (Total Products, Total Revenue, Total Sold, Expenses / COGS).
- **Analysis Screen**:
  - Business performance metrics (Total Revenue, Total Profit, Total Units Sold).
- **Stock Track Screen (Inventory Management)**:
  - Real-time stock tracking with inventory items.
  - Status badges with optimized UX coloring: **Green** for High, **Yellow (Amber)** for Medium, and **Red** for Low / Out of Stock.
  - Interactive bottom sheet context menu for each item supporting **Quick Restock**, **Fix Mistake / Edit Details**, and **Delete Product Listing**.
  - Duplicate product prevention advising users to use Quick Restock.
- **More Screen**:
  - Comprehensive settings & features list: Vendor Intelligence, Change Language, Disable Offline Mode, Toggle Dark/Light Mode, Data Sync Status, Voice Mode, Backup & Restore, and Support Chat.
- **Record Sale Screen**:
  - Autocomplete & dropdown product lookup linked to inventory with automatic category and cost price auto-fill.
  - Zimbabwean Multi-Currency support: **`USD`**, **`ZiG`**, and **`Rand (ZAR)`**.
  - Local Payment Methods: **`Cash`**, **`EcoCash`**, **`OneMoney`**, and **`Credit given (Chikwereti)`**.
  - Real-time live profit calculation with safety guards against empty input states.
  - Today's sales list and automatic SQLite inventory stock deduction upon saving.

### 2. Zimbabwean Market Context & Architecture
- **Chikwereti (Credit given)**: Isolates customer debt and credit sales from immediate liquid cash flow in database revenue/profit aggregations (`payment_method != 'Credit given (Chikwereti)'`), preventing "ghost" cash collections.
- **Immutable Sales Snapshot Architecture**: Stores static price/category snapshots in individual sale records to insulate historical financial logs from future inventory wholesale cost fluctuations.
- **Strict Input Security & Validation**: Fortified numerical inputs with integer-only and 2-decimal precision formatters (`FilteringTextInputFormatter`) and rigorous form validators to block data entry threats.

---

## Tech Stack

| Layer | Technology | Purpose |
|-|-|-|
| Mobile | Flutter 3.44.8 (Dart) | Cross-platform Android app |
| Local DB | SQLite (sqflite) | Offline-first data storage & unique constraints |
| Cloud DB | Supabase (PostgreSQL) | Cloud sync + authentication (Phase 3+) |
| Research | R / tidymodels | Credit scoring model |
| Version Control | Git / GitHub | Full history from day one |

---

## Repository Structure


```
MusikaKhula/
|- mobile_app/          <- Flutter project (Phases 0-5)
|   |- lib/
|   |   |- models/      <- Data structures (Sale, InventoryItem)
|   |   |- services/    <- Database layer (DatabaseHelper singleton)
|   |   |- screens/     <- Implemented Phase 1 screens (Home, Analysis, StockTrack, More, RecordSale)
|   |   |- main.dart    <- App entry point & theme configuration
|   |- pubspec.yaml     <- Package dependencies
```

---

## Developer

**Dean** : BSc Honours Informatics, Year 2  
National University of Science & Technology (NUST), Bulawayo, Zimbabwe

---

*MusikaKhula - Empowering Zimbabwe's informal economy, one sale at a time.*
