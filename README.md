# Habit Tracker

A Flutter application for tracking daily habits, journaling, mapping habits to routine activities, and tracking expenses — all backed by Supabase.

## Features

### Habits
- Create, edit, and delete habits with daily/weekly/custom frequency
- Toggle daily completion with a single tap
- View current streaks and a 30-day completion calendar
- Daily progress summary

### Journal
- **Morning entry** — set intentions and goals at the start of the day
- **Evening reflection** — reflect on the day with mood tracking
- **Status management** — mark entries as pending, in progress, or completed
- Tag entries for easy filtering

### Activity-Habit Mapping
- Link habits to your daily routine (e.g., "After brushing teeth → Read 20 pages")
- Suggested trigger activities for quick setup
- Enable/disable mappings with a toggle
- Add notes for context

### Expense Tracking
- Create custom spending categories with icons and colors
- Log expenses with amount, category, description, and date
- Monthly spending summary with pie chart breakdown
- Browse and manage transactions

## Setup

### 1. Supabase Project

1. Create a free project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run the contents of `supabase/schema.sql`
3. Copy your **Project URL** and **anon public key** from **Settings → API**

### 2. Configure the App

Edit `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';
}
```

### 3. Run the App

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── config/          # Supabase config, app theme
├── models/          # Data models (Habit, JournalEntry, ActivityMapping, Expense)
├── services/        # Supabase service layer
├── providers/       # State management (ChangeNotifier + Provider)
├── screens/
│   ├── home/        # Main shell with bottom navigation
│   ├── habits/      # Habit list, detail, add dialog
│   ├── journal/     # Journal list, morning entry, evening reflection
│   ├── activity_mapping/  # Routine mapping list, add/edit dialog
│   └── expenses/    # Expense list, chart, categories, add dialog
└── main.dart
```

## Tech Stack

- **Flutter** with Material 3
- **Supabase** (PostgreSQL backend, real-time capable)
- **Provider** for state management
- **fl_chart** for expense pie charts
- **intl** for date formatting
- **uuid** for client-side ID generation
