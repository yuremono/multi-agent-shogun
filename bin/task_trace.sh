#!/bin/bash
# タスク履歴を表示・参照するスクリプト

# ヘルプメッセージ
show_help() {
  echo "Usage: task_trace.sh [OPTION]"
  echo ""
  echo "Options:"
  echo "  --recent [N]      最近のN件の履歴を表示（デフォルト10件）"
  echo "  --summary        全タスクの統計情報を表示"
  echo "  --worker <id>    特定のワーカーの履歴を表示"
  echo "  --task <id>      特定のタスクの履歴を表示"
  echo "  --status <status> 特定のステータスの履歴を表示"
  echo ""
  echo "Examples:"
  echo "  task_trace.sh --recent 5"
  echo "  task_trace.sh --summary"
  echo "  task_trace.sh --worker ashigaru1"
  echo "  task_trace.sh --task cmd_024"
  echo "  task_trace.sh --status done"
}

# コマンドライン引数の解析
case "$1" in
  --recent)
    LIMIT="${2:-10}"
    echo "=== 最近の${LIMIT}件のタスク履歴 ==="
    sqlite3 -header -column queue/traces.db "
      SELECT
        id,
        task_id,
        worker_id,
        parent_cmd,
        status,
        started_at,
        completed_at,
        duration_seconds
      FROM task_executions
      ORDER BY started_at DESC
      LIMIT $LIMIT;
    "
    ;;

  --summary)
    echo "=== タスク統計サマリー ==="
    sqlite3 queue/traces.db "
      SELECT
        worker_id,
        COUNT(*) as total_tasks,
        SUM(CASE WHEN status='done' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status='failed' THEN 1 ELSE 0 END) as failed,
        SUM(CASE WHEN status='in_progress' THEN 1 ELSE 0 END) as in_progress,
        ROUND(AVG(CASE WHEN status='done' THEN duration_seconds ELSE NULL END), 1) as avg_duration_sec
      FROM task_executions
      GROUP BY worker_id
      ORDER BY worker_id;
    "
    ;;

  --worker)
    if [ -z "$2" ]; then
      echo "エラー: ワーカーIDを指定してください"
      echo "Usage: task_trace.sh --worker <worker_id>"
      exit 1
    fi
    echo "=== ワーカー $2 のタスク履歴 ==="
    sqlite3 -header -column queue/traces.db "
      SELECT
        id,
        task_id,
        parent_cmd,
        status,
        started_at,
        completed_at,
        duration_seconds
      FROM task_executions
      WHERE worker_id='$2'
      ORDER BY started_at DESC;
    "
    ;;

  --task)
    if [ -z "$2" ]; then
      echo "エラー: タスクIDを指定してください"
      echo "Usage: task_trace.sh --task <task_id>"
      exit 1
    fi
    echo "=== タスク $2 の履歴 ==="
    sqlite3 -header -column queue/traces.db "
      SELECT
        id,
        worker_id,
        parent_cmd,
        status,
        started_at,
        completed_at,
        duration_seconds
      FROM task_executions
      WHERE task_id='$2'
      ORDER BY id;
    "
    ;;

  --status)
    if [ -z "$2" ]; then
      echo "エラー: ステータスを指定してください"
      echo "Usage: task_trace.sh --status <status>"
      echo "ステータス例: done, failed, in_progress"
      exit 1
    fi
    echo "=== ステータス '$2' のタスク履歴 ==="
    sqlite3 -header -column queue/traces.db "
      SELECT
        id,
        task_id,
        worker_id,
        parent_cmd,
        started_at,
        completed_at,
        duration_seconds
      FROM task_executions
      WHERE status='$2'
      ORDER BY started_at DESC;
    "
    ;;

  *)
    show_help
    exit 1
    ;;
esac
