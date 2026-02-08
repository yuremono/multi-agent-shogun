#!/bin/bash
# 簡易トレースデータベース初期化スクリプト
DB_PATH="queue/traces.db"

sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS task_executions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  worker_id TEXT NOT NULL,
  parent_cmd TEXT,
  status TEXT,
  started_at TEXT,
  completed_at TEXT,
  duration_seconds INTEGER,
  UNIQUE(task_id, worker_id)
);
CREATE INDEX IF NOT EXISTS idx_worker_id ON task_executions(worker_id);
CREATE INDEX IF NOT EXISTS idx_status ON task_executions(status);
CREATE INDEX IF NOT EXISTS idx_started_at ON task_executions(started_at);
EOF
