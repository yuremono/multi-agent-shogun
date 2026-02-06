# トラブルシューティングガイド

multi-agent-shogun システムで発生しがちな問題とその解決方法をまとめています。

---

## 🚀 最も簡単な起動方法

まずはこれを試してください。

```bash
# 1. 出陣スクリプトを実行（全自動でセットアップ）
./shutsujin_departure.sh

# 2. 将軍に接続
css

# 3. 家老・足軽に接続（別タブで）
csm
```

**これだけで動きます！** 問題が発生した場合のみ、以下のトラブルシューティングを参照してください。
tmux kill-session -t shogun
tmux kill-session -t multiagent
---

## 目次

1. [起動時の問題](#起動時の問題)
2. [エージェントが応答しない](#エージェントが応答しない)
3. [tmux関連の問題](#tmux関連の問題)
4. [Claude Code関連の問題](#claude-code関連の問題)

---

## 起動時の問題

### ❌ 問題: `duplicate session` エラーが発生する

**エラーメッセージ例:**
```
【戦】 👑 将軍の本陣を構築中...
duplicate session: shogun
```

**原因:**
`.tmux.conf` に `tmux-continuum` プラグインの自動復元設定が有効になっています。スクリプトが新しいセッションを作成しようとすると、continuumが自動的に前回のセッションを復元してしまい、競合が発生します。

**解決方法:**

1. `.tmux.conf` を編集して continuum の自動復元を無効化：

```bash
# ~/.tmux.conf の以下の行を変更
# 変更前:
set -g @continuum-restore 'on'

# 変更後:
set -g @continuum-restore 'off'
```

2. tmuxサーバーを完全に停止してから再実行：

```bash
tmux kill-server
./shutsujin_departure.sh
```

**確認方法:**
```bash
# continuum設定が無効になっているか確認
grep @continuum-restore ~/.tmux.conf
# off と表示されればOK
```

---

### ❌ 問題: スクリプトが途中で終了する

**症状:**
```
【戦】 👑 将軍の本陣を構築中...
（ここで終了してしまう）
```

**原因:**
- tmuxがインストールされていない
- Claude Code CLIがインストールされていない
- シェル設定ファイルに自動実行される設定が競合している

**解決方法:**

```bash
# 1. 必要なツールがインストールされているか確認
which tmux
which claude

# 2. なければインストール
brew install tmux
npm install -g @anthropic-ai/claude-code

# 3. 初回セットアップを再実行
./first_setup.sh
```

---

## エージェントが応答しない

### ❌ 問題: 将軍や家老が武士のような言葉で喋らない

**症状:**
- 普通のClaude Codeとしてしか応答しない
- 「殿」「でござる」といった言葉が出てこない

**原因:**
指示書（`instructions/shogun.md` など）が読み込まれていません。

**解決方法:**

```bash
# 1. 一旦セッションを削除
tmux kill-server

# 2. 再度スクリプトを実行
./shutsujin_departure.sh

# 3. 将軍に接続して確認
css
# 「承知つかまつった！」などの言葉が出ればOK
```

**手動で指示書を読み込ませる方法:**

```bash
# 将軍の場合
tmux send-keys -t shogun:main 'instructions/shogun.md を読んで役割を理解せよ。' Enter

# 家老の場合
tmux send-keys -t multiagent:agents.0 'instructions/karo.md を読んで役割を理解せよ。' Enter
```

---

### ❌ 問題: エージェントが「thinking」のまま進まない

**症状:**
```
⠋ Thinking...  （ずっとこのまま）
```

**解決方法:**

1. **Escキーで割り込み:**
   ```
   Esc
   ```

2. **プロセスを再起動:**

```bash
# 将軍を再起動
tmux respawn-pane -t shogun:main -k 'claude --model opus --dangerously-skip-permissions'

# 家老を再起動
tmux respawn-pane -t multiagent:agents.0 -k 'claude --model opus --dangerously-skip-permissions'
```

3. **モデルを変更してコスト削減:**

```bash
# 将軍のセッションで
/model sonnet
```

---

## tmux関連の問題

### ❌ 問題: tmuxセッションに接続できない

**エラーメッセージ例:**
```
no server running on /private/tmp/tmux-502/default
```

**原因:**
tmuxサーバーが起動していません。

**解決方法:**

```bash
# 出陣スクリプトを実行
./shutsujin_departure.sh
```

---

### ❌ 問題: セッションがネストしている（入れ子状態）

**症状:**
- 画面がおかしくなる
- キー入力が効かない

**原因:**
既存のtmuxセッション内で `css` や `csm` エイリアスを実行してしまいました。

**解決方法:**

1. **デタッチ（内側のセッションから離脱）:**
   ```
   Ctrl+B → D
   ```

2. **外側のプロンプトで直接claudeを実行:**
   ```bash
   claude --model opus --dangerously-skip-permissions
   ```

3. **強制リセット（最終手段）:**
   ```bash
   tmux respawn-pane -k
   ```

---

### ❌ 問題: マウススクロールが効かない

**解決方法:**

```bash
# ~/.tmux.conf に以下を追加（または確認）
set -g mouse on
setw -g mode-keys vi
```

設定変更後、tmuxセッションを再起動：

```bash
tmux source-file ~/.tmux.conf
```

---

## Claude Code関連の問題

### ❌ 問題: Claude Codeが起動しない

**エラーメッセージ例:**
```
claude: command not found
```

**解決方法:**

```bash
# 1. Node.jsがインストールされているか確認
node --version

# 2. Claude Code CLIをインストール
npm install -g @anthropic-ai/claude-code

# 3. パスを確認
which claude
# /Users/xxx/.nvm/versions/node/vxx.x.x/bin/claude などが表示されればOK
```

---

### ❌ 問題: APIキーの認証エラー

**エラーメッセージ例:**
```
Error: Authentication failed
```

**解決方法:**

```bash
# 1. APIキーを設定
claude auth

# 2. または環境変数を設定
export ANTHROPIC_API_KEY="your-api-key-here"

# 3. ~/.zshrc に追加（永続化）
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

---

### ❌ 問題: モデルが切り替わらない

**解決方法:**

```bash
# 将軍のセッションで以下を実行
/model opus
# または
/model sonnet
```

**注意:** `--model` オプションで起動している場合、初期モデルは固定されます。途中で変更するには `/model` コマンドを使用します。

---

## トラブルシューティングのチェックリスト

問題が発生したら、以下の順序で確認してください：

1. **tmuxサーバーの状態確認**
   ```bash
   tmux ls
   ```

2. **tmuxサーバーの再起動**
   ```bash
   tmux kill-server
   ./shutsujin_departure.sh
   ```

3. **ツールのインストール確認**
   ```bash
   which tmux
   which claude
   ```

4. **設定ファイルの確認**
   ```bash
   # continuumが無効になっているか
   grep @continuum-restore ~/.tmux.conf

   # 言語設定
   cat config/settings.yaml
   ```

5. **ログの確認**
   ```bash
   # ログディレクトリを確認
   ls -la logs/
   ```

---

## 再インストールが必要な場合

問題が解決しない場合、クリーンインストールを検討してください：

```bash
# 1. tmuxサーバーを停止
tmux kill-server

# 2. セッション関連のファイルを削除
rm -rf queue/*.yaml queue/tasks/* queue/reports/*

# 3. dashboardをリセット
rm dashboard.md

# 4. 再インストール
./first_setup.sh

# 5. 出陣
./shutsujin_departure.sh
```

---

## サポート

問題が解決しない場合は：

1. **GitHub Issues:** https://github.com/yohey-w/multi-agent-shogun/issues
2. **エラーログを添付:** `logs/` ディレクトリの内容を添付してください

---

## よくある質問（FAQ）

### Q: tmuxを勉強しないと使えませんか？
A: 基本的な操作は以下のコマンドだけで十分です：
- `css` - 将軍に接続
- `csm` - 家老・足軽に接続
- `Ctrl+B → D` - セッションから離脱

### Q: スマホから操作できますか？
A: はい。Tailscale + Termux（Android）または Blink Shell（iOS）で可能です。詳細は README を参照してください。

### Q: コストはどれくらいかかりますか？
A: モデル構成によりますが、平時の陣（Sonnet4体+Opus5体）で1時間あたり約数千円程度です。`/clear` でコンテキストをリセットしてコスト削減が可能です。

---

*最終更新: 2026-02-05*
