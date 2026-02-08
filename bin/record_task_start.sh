#!/bin/bash
# タスク開始記録スクリプト
# 使用法: bin/record_task_start.sh <TASK_ID> <WORKER_ID> <PARENT_CMD>

TASK_ID="$1"
WORKER_ID="$2"
PARENT_CMD="$3"
STARTED_AT=$(date "+%Y-%m-%dT%H:%M:%S")

# 引数チェック
if [ -z "$TASK_ID" ] || [ -z "$WORKER_ID" ] || [ -z "$PARENT_CMD" ]; then
  echo "エラー: 引数が不足しています"
  echo "使用法: $0 <TASK_ID> <WORKER_ID> <PARENT_CMD>"
  exit 1
fi

# データベースが存在するか確認
if [ ! -f "queue/traces.db" ]; then
  echo "エラー: データベースファイルが存在しません (queue/traces.db)"
  echo "先に bin/init_trace_db.sh を実行してください"
  exit 1
fi

# タスク開始を記録
sqlite3 queue/traces.db <<EOF
INSERT INTO task_executions (task_id, worker_id, parent_cmd, status, started_at)
VALUES ('$TASK_ID', '$WORKER_ID', '$PARENT_CMD', 'in_progress', '$STARTED_AT');
EOF

if [ $? -eq 0 ]; then
  echo "タスク開始を記録しました: task_id=$TASK_ID, worker_id=$WORKER_ID, started_at=$STARTED_AT"
else
  echo "エラー: データベースへの記録に失敗しました"
  exit 1
fi
