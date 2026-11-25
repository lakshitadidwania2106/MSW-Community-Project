"""SQLite schema. Free-form fields (post body, job details, etc.) live in a JSON `data` column."""

SCHEMA = """
PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, role TEXT NOT NULL,
  data TEXT NOT NULL DEFAULT '{}', status TEXT NOT NULL DEFAULT 'Active',
  is_admin INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT, author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  data TEXT NOT NULL, likes INTEGER NOT NULL DEFAULT 0, hidden INTEGER NOT NULL DEFAULT 0,
  pinned INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT, post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, text TEXT NOT NULL, time TEXT DEFAULT 'now',
  likes INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS post_likes (post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE, user_id TEXT, PRIMARY KEY (post_id, user_id));
CREATE TABLE IF NOT EXISTS post_saves (post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE, user_id TEXT, PRIMARY KEY (post_id, user_id));
CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, data TEXT NOT NULL,
  registered INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS event_registrations (
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE, user_id TEXT, team TEXT, track TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (event_id, user_id)
);
CREATE TABLE IF NOT EXISTS announcements (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, title TEXT NOT NULL, body TEXT NOT NULL, organiser TEXT,
  category TEXT, link TEXT, pinned INTEGER NOT NULL DEFAULT 0, time TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS opportunities (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, data TEXT NOT NULL, applicants INTEGER NOT NULL DEFAULT 0,
  live INTEGER NOT NULL DEFAULT 1, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS applications (
  opportunity_id INTEGER REFERENCES opportunities(id) ON DELETE CASCADE, user_id TEXT, link TEXT, note TEXT,
  status TEXT NOT NULL DEFAULT 'Applied', created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (opportunity_id, user_id)
);
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, data TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS submissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT, task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE, user_id TEXT,
  repo TEXT, demo TEXT, notes TEXT, shots TEXT DEFAULT '[]', status TEXT NOT NULL DEFAULT 'In review',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS ideas (
  id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, raised REAL NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS idea_decisions (
  idea_id INTEGER REFERENCES ideas(id) ON DELETE CASCADE, user_id TEXT, decision TEXT NOT NULL, amount REAL DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (idea_id, user_id)
);
"""

TABLES = ["users", "posts", "comments", "post_likes", "post_saves", "events", "event_registrations", "announcements",
          "opportunities", "applications", "tasks", "submissions", "ideas", "idea_decisions"]
