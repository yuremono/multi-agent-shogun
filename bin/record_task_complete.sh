#!/bin/bash
# タスク完了記録スクリプト
# 使用法: bin/record_task_complete.sh <TASK_ID> <WORKER_ID> <STATUS>

TASK_ID="$1"
WORKER_ID="$2"
STATUS="$3"
COMPLETED_AT=$(date "+%Y-%m-%dT%H:%M:%S")

# 引数チェック
if [ -z "$TASK_ID" ] || [ -z "$WORKER_ID" ] || [ -z "$STATUS" ]; then
  echo "エラー: 引数が不足しています"
  echo "使用法: $0 <TASK_ID> <WORKER_ID> <STATUS>"
  echo "STATUS: done | failed | blocked"
  exit 1
fi

# ステータスの妥当性チェック
if [ "$STATUS" != "done" ] && [ "$STATUS" != "failed" ] && [ "$STATUS" != "blocked" ]; then
  echo "エラー: STATUSは 'done', 'failed', 'blocked' のいずれかである必要があります"
  exit 1
fi

# データベースが存在するか確認
if [ ! -f "queue/traces.db" ]; then
  echo "エラー: データベースファイルが存在しません (queue/traces.db)"
  exit 1
fi

# 開始時刻を取得
STARTED_AT=$(sqlite3 queue/traces.db "SELECT started_at FROM task_executions WHERE task_id='$TASK_ID' AND worker_id='$WORKER_ID' AND status='in_progress' ORDER BY id DESC LIMIT 1;" 2>/dev/null)

if [ -n "$STARTED_AT" ]; then
  # 開始時刻と完了時刻の差分を計算（秒）
  # macOSのdateコマンドの形式
  START_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$STARTED_AT" "+%s" 2>/dev/null || echo 0)
  END_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$COMPLETED_AT" "+%s" 2>/dev/null || echo 0)
  DURATION=$((END_SEC - START_SEC))

  # 負の値の場合は0にする
  if [ $DURATION -lt 0 ]; then
    DURATION=0
  fi
else
  DURATION=0
fi

# タスク完了を記録
sqlite3 queue/traces.db <<EOF
UPDATE task_executions
SET status='$STATUS', completed_at='$COMPLETED_AT', duration_seconds=$DURATION
WHERE task_id='$TASK_ID' AND worker_id='$WORKER_ID' AND status='in_progress';
EOF

if [ $? -eq 0 ]; then
  echo "タスク完了を記録しました: task_id=$TASK_ID, worker_id=$WORKER_ID, status=$STATUS, duration=${DURATION}秒"
else
  echo "エラー: データベースへの記録に失敗しました"
  exit 1
fi
