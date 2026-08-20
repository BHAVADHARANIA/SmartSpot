const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'smartspot.db');
const db = new Database(DB_PATH);

db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// ---------- Schema ----------
db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS reminders (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  notes TEXT,
  latitude REAL,
  longitude REAL,
  radius_meters REAL DEFAULT 100,
  category TEXT,
  condition_type TEXT DEFAULT 'arrive', -- arrive | leave | time | combo
  scheduled_at TEXT,
  status TEXT NOT NULL DEFAULT 'active', -- active | completed | archived
  is_favorite INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS reminder_conditions (
  id TEXT PRIMARY KEY,
  reminder_id TEXT NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  value TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS favorite_locations (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  address TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS location_visits (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  label TEXT,
  visited_at TEXT NOT NULL DEFAULT (datetime('now')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_reminders_user ON reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorite_locations(user_id);
CREATE INDEX IF NOT EXISTS idx_visits_user ON location_visits(user_id);
`);

module.exports = db;
