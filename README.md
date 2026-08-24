# 🏐 Sky Spike Academy Management App (أكاديمية سكاي سبايك للكرة الطائرة)

A complete, production-ready, offline-first Android management app designed specifically for volleyball academies and sports clubs. Built with **Flutter (Null-Safety)**, **SQLite (Relational Schema with Foreign Keys & Auto-Migration)**, and **Clean Architecture (Feature-First Provider State Management)**.

---

## 🌟 Key Features

1. **📊 Real-time Dashboard & Alerts**:
   - Live KPI metric cards: Active Trainees, Today's Attendance count, Monthly Collected Revenue, Total Outstanding Debt.
   - Smart alert engine highlighting trainees with **zero remaining sessions** and trainees with **unpaid debts**.
   - Quick action shortcuts to register trainees, roll call attendance, and record payments.

2. **👥 Trainee Lifecycle & Profile Management**:
   - Comprehensive Trainee profile with full personal info, session balance, and financial status.
   - Real-time attendance progress bar (`attended / total sessions`) with color-coded badges.
   - Instant subscription renewal dialog with automatic session and fee calculations.
   - Search by name or phone, plus advanced filtering by Group, Status (Active/Suspended/Expired), and Debt balance.

3. **🏐 Daily Attendance Roll Call**:
   - Interactive 3-state attendance toggles: **حاضر (Present)**, **غائب (Absent)**, **معتذر (Excused)**.
   - Date picker with previous/next day quick navigation.
   - Automatic decrement/increment and transactional recalculation of trainee session counts.
   - Batch saving and bulk actions (Mark All Present / Clear).

4. **💰 Finance, Payments & Subscription Plans**:
   - Debt collection tracker with one-tap payment collection.
   - Multiple payment method support: **كاش (Cash)**, **إنستاباي (InstaPay)**, **فودافون كاش (Vodafone Cash)**, **فيزا / بطاقة بنكية (Card)**.
   - Full-featured Subscription Plans Manager (Add / Edit / Safe Delete with FK protection).

5. **📈 Monthly Analytics & Multi-Format Exporting**:
   - Monthly performance breakdown (attendance rate %, payment method distribution, group headcounts).
   - One-tap export to **formatted WhatsApp summary text** with Arabic emojis and statistics.
   - One-tap export to **UTF-8 Arabic CSV table** for direct opening in Microsoft Excel and Google Sheets.

6. **🌍 Native Arabic (RTL) & Volleyball Theme**:
   - Native Right-to-Left (RTL) Arabic typography and localized date/currency formatting.
   - Custom Volleyball visual identity: Deep Navy Blue (`#1A237E`) and Energetic Sunset Orange (`#FF6F00`).

---

## 🗄 Relational Database Schema

```sql
-- 1. Subscription Plans Table
CREATE TABLE plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  sessions_count INTEGER NOT NULL,
  price REAL NOT NULL,
  duration_days INTEGER NOT NULL
);

-- 2. Trainees Table (Foreign Key -> plans)
CREATE TABLE trainees (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  age INTEGER NOT NULL,
  group_name TEXT NOT NULL,
  plan_id INTEGER NOT NULL,
  total_sessions INTEGER NOT NULL,
  attended_sessions INTEGER NOT NULL DEFAULT 0,
  total_fee REAL NOT NULL,
  paid_amount REAL NOT NULL DEFAULT 0.0,
  status TEXT NOT NULL DEFAULT 'Active',
  join_date TEXT NOT NULL,
  FOREIGN KEY (plan_id) REFERENCES plans (id) ON DELETE RESTRICT
);

-- 3. Attendance Table (Foreign Key -> trainees, Unique composite key)
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trainee_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  FOREIGN KEY (trainee_id) REFERENCES trainees (id) ON DELETE CASCADE,
  UNIQUE (trainee_id, date)
);

-- 4. Payments Table (Foreign Key -> trainees)
CREATE TABLE payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trainee_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (trainee_id) REFERENCES trainees (id) ON DELETE CASCADE
);
```

---

## 📁 Project Directory Structure

```
sky_spike_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── lib/
    ├── main.dart
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart
    │   │   ├── app_strings.dart
    │   │   └── app_styles.dart
    │   ├── database/
    │   │   ├── app_database.dart
    │   │   └── seed_data.dart
    │   ├── theme/
    │   │   └── app_theme.dart
    │   └── utils/
    │       ├── date_formatter.dart
    │       └── dialog_helper.dart
    ├── models/
    │   ├── plan_model.dart
    │   ├── trainee_model.dart
    │   ├── attendance_model.dart
    │   └── payment_model.dart
    ├── repositories/
    │   ├── plan_repository.dart
    │   ├── trainee_repository.dart
    │   ├── attendance_repository.dart
    │   ├── payment_repository.dart
    │   └── report_repository.dart
    ├── providers/
    │   ├── dashboard_provider.dart
    │   ├── trainee_provider.dart
    │   ├── attendance_provider.dart
    │   ├── finance_provider.dart
    │   └── plan_provider.dart
    ├── screens/
    │   ├── main_navigation_screen.dart
    │   ├── dashboard/
    │   │   ├── dashboard_screen.dart
    │   │   └── widgets/
    │   │       ├── kpi_card.dart
    │   │       ├── alert_card.dart
    │   │       └── quick_action_button.dart
    │   ├── trainees/
    │   │   ├── trainees_list_screen.dart
    │   │   ├── trainee_detail_screen.dart
    │   │   ├── trainee_form_screen.dart
    │   │   └── widgets/
    │   │       ├── trainee_card.dart
    │   │       └── trainee_filter_bottom_sheet.dart
    │   ├── attendance/
    │   │   ├── daily_attendance_screen.dart
    │   │   └── widgets/
    │   │       ├── attendance_tile.dart
    │   │       └── attendance_summary_bar.dart
    │   ├── finance/
    │   │   ├── finance_screen.dart
    │   │   ├── plans_management_screen.dart
    │   │   ├── plan_form_dialog.dart
    │   │   ├── record_payment_dialog.dart
    │   │   └── widgets/
    │   │       ├── debt_card.dart
    │   │       └── payment_history_tile.dart
    │   └── reports/
    │       ├── reports_screen.dart
    │       └── widgets/
    │           └── export_options_sheet.dart
    └── widgets/
        ├── custom_app_bar.dart
        ├── empty_state_view.dart
        ├── custom_text_field.dart
        ├── custom_dropdown.dart
        └── badge_tag.dart
```

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio / VS Code with Flutter Extension
- Android SDK (API Level 21+)

### 2. Run the App
```bash
# Navigate to the project directory
cd sky_spike_app

# Fetch dependencies
flutter pub get

# Run on connected Android device or emulator
flutter run
```

### 3. Immediate Testing with Seed Data
On first launch, the app automatically inserts realistic mock data into SQLite:
- 4 Subscription Packages (Basics 8 sessions, Advanced 12 sessions, Intensive 16 sessions, Cubs 6 sessions).
- 8 Trainees across groups with active attendance records, paid transactions, zero sessions alerts, and overdue debts.
