# 公式 Agent Teams テスト手順

Claude Opus 4.6 の公式 Agent Teams 機能を試すための手順メモ。

---

## ステップ1: テストプロジェクトの作成

```bash
# ホームディレクトリにテスト用プロジェクトを作成
mkdir ~/test-agent-teams
cd ~/test-agent-teams

# READMEファイル作成
echo '# Test Project for Agent Teams' > README.md
```

---

## ステップ2: Claude Code 設定ファイルの作成

```bash
# .claudeディレクトリとsettings.jsonの作成
mkdir -p .claude

cat > .claude/settings.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "high"
  },
  "teammateMode": "tmux"
}
EOF
```

**設定の説明**:
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`: Agent Teams機能を有効化
- `CLAUDE_CODE_EFFORT_LEVEL`: 推論レベル（highで深い思考）
- `teammateMode: "tmux"`: tmux分割ペインモードを使用

---

## ステップ3: Claude Code の起動

```bash
# Claude Codeを起動
claude
```

---

## ステップ4: Agent Teams のテスト

Claude Code内で以下のプロンプトを実行：

```
エージェントチームを作って、このREADMEの改善案を3つの視点（UX、技術、品質）で出してください
```

または：

```
Create an agent team with 3 teammates to review this README:
- One focused on UX and clarity
- One checking technical accuracy
- One validating completeness
```

---

## 期待される動作

1. tmuxセッションが自動的に作成される
2. 複数の分割ペインが表示される
3. 各ペインでチームメイトが独立して動作
4. リーダーが結果を統合して返答

---

## 備考: shogunプロジェクトとの違い

| 項目 | shogunプロジェクト | 公式 Agent Teams |
|------|-------------------|------------------|
| tmux起動 | 手動でスクリプト実行 | Claude Codeが自動管理 |
| 通信方式 | YAML + send-keys | 組み込みメッセージング |
| ポーリング | 禁止（send-keys必須） | 不要（自動通知） |
| 役割階層 | 将軍→家老→足軽 | リーダー + メンバー（フラット） |

---

## クリーンアップ（テスト終了後）

```bash
# テストプロジェクトの削除
rm -rf ~/test-agent-teams
```
