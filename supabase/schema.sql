-- Habit Tracker - Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor to set up all required tables.

-- ─── Habits ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  frequency TEXT NOT NULL DEFAULT 'daily', -- daily, weekly, custom
  custom_days INTEGER[], -- 1=Mon, 7=Sun
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Habit Logs ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS habit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  note TEXT,
  UNIQUE(habit_id, date)
);

CREATE INDEX IF NOT EXISTS idx_habit_logs_date ON habit_logs(date);
CREATE INDEX IF NOT EXISTS idx_habit_logs_habit_id ON habit_logs(habit_id);

-- ─── Journal Entries ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL UNIQUE,
  morning_entry TEXT NOT NULL,
  evening_reflection TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, in_progress, completed
  mood TEXT, -- great, good, okay, bad, terrible
  tags TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_journal_entries_date ON journal_entries(date);

-- ─── Activity Mappings ───────────────────────────────────

CREATE TABLE IF NOT EXISTS activity_mappings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trigger_activity TEXT NOT NULL,
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  mapped_action TEXT NOT NULL,
  notes TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_mappings_habit_id ON activity_mappings(habit_id);

-- ─── Expense Categories ──────────────────────────────────

CREATE TABLE IF NOT EXISTS expense_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Expenses ────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES expense_categories(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);

-- ─── Manifestations ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS manifestations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  affirmation TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL DEFAULT 'personal_growth', -- career, health, relationships, financial, personal_growth, spiritual
  status TEXT NOT NULL DEFAULT 'active', -- active, manifesting, manifested, released
  target_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  manifested_at TIMESTAMPTZ
);

-- ─── Manifestation Practices ──────────────────────────────

CREATE TABLE IF NOT EXISTS manifestation_practices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manifestation_id UUID NOT NULL REFERENCES manifestations(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  affirmed BOOLEAN NOT NULL DEFAULT false,
  visualized BOOLEAN NOT NULL DEFAULT false,
  gratitude_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(manifestation_id, date)
);

CREATE INDEX IF NOT EXISTS idx_manifestation_practices_date ON manifestation_practices(date);
CREATE INDEX IF NOT EXISTS idx_manifestation_practices_mid ON manifestation_practices(manifestation_id);

-- ─── Manifestation Signs ──────────────────────────────────

CREATE TABLE IF NOT EXISTS manifestation_signs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manifestation_id UUID NOT NULL REFERENCES manifestations(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_manifestation_signs_mid ON manifestation_signs(manifestation_id);

-- ─── Row Level Security (RLS) ────────────────────────────
-- For a single-user app, you can enable RLS and create policies
-- based on your Supabase auth setup. Below is a permissive policy
-- that allows all operations (suitable for development / anon key usage).

ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Permissive policies for development (allow all via anon key)
CREATE POLICY "Allow all on habits" ON habits FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on habit_logs" ON habit_logs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on journal_entries" ON journal_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on activity_mappings" ON activity_mappings FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on expense_categories" ON expense_categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on expenses" ON expenses FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE manifestations ENABLE ROW LEVEL SECURITY;
ALTER TABLE manifestation_practices ENABLE ROW LEVEL SECURITY;
ALTER TABLE manifestation_signs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all on manifestations" ON manifestations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on manifestation_practices" ON manifestation_practices FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on manifestation_signs" ON manifestation_signs FOR ALL USING (true) WITH CHECK (true);
