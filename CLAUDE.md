# Agent Teams インフラ構成

> **Version**: 4.0
> **Last Updated**: 2026-02-09
> **Architecture**: Agent Teams + tmux

---

## ⚠️ CRITICAL: このファイルの対象者

**このファイルはチームリーダー（メインエージェント）専用です。**

**以下のエージェントはこのファイルを読まないでください：**
- `~/.claude/agents/` で定義された全てのカスタムエージェント
- architect, reviewer, tester, fixer, doc, general などのチームメンバー

各チームメンバーは `~/.claude/agents/{name}.md` を読んでください。

---

## 概要

このディレクトリは、Claude Codeの**Agent Teams機能**と**tmux**を組み合わせたマルチエージェント並列開発基盤です。
**以下インフラと称し、作業するディレクトリをプロジェクトと称します。**

```
ユーザー（人間）
  │
  ▼ 指示
┌──────────────────────┐
│   チームリーダー     │ ← あなた（このCLAUDE.mdを読む）
│   (メインエージェント) │
└──────────┬───────────┘
           │ Task toolで起動
           ▼
┌─────────────────────────────────┐
│         Agent Team              │
│  ┌──────┬────┬───┬───┬───┬───┐│
│  │archi │revi│tes│fix│doc│gen││
│  │tect  │ewer│ter│er│   │eral││
│  └──────┴────┴───┴───┴───┴───┘│
└─────────────────────────────────┘
           │
           ▼ tmux通知（オプション）
     ユーザー・他チームへ通知
```

---

## セッション開始時の必須行動（リーダー専用）

新たなセッションを開始した際は、作業前に必ず以下を実行せよ：

### Step 1: Memory MCPの確認
```bash
mcp__memory__read_graph
```
Memory MCPに保存されたルール・コンテキスト・禁止事項を確認せよ。

### Step 2: 利用可能なエージェントの確認
```bash
ls ~/.claude/agents/
```
利用可能なカスタムエージェント定義を確認せよ。

---

## チーム編成ルール（リーダー専用）

### 基本エージェント一覧

| エージェント名 | 役割 | 使用タイミング |
|--------------|------|--------------|
| **architect** | 設計・計画 | 新機能の計画、アーキテクチャ決定 |
| **tester** | テスト・TDD | 新機能開発、バグ修正時 |
| **fixer** | エラー解決・クリーンアップ | ビルド失敗時、型エラー時 |
| **reviewer** | レビュー・検証 | コードレビュー、品質チェック |
| **doc** | ドキュメント更新 | README、コードマップ更新時 |
| **general** | 汎用作業 | その他のタスク |

### チーム作成手順

```python
# 1. チームの作成
TeamCreate(
    team_name="project-name",
    description="プロジェクト説明"
)

# 2. メンバーの追加（Task toolで）
Task(
    subagent_type="architect",
    team_name="project-name",
    description="設計タスク",
    prompt="設計内容..."
)

Task(
    subagent_type="tester",
    team_name="project-name",
    description="テストタスク",
    prompt="テスト内容..."
)
```

### プロジェクトタイプ別推奨編成

| プロジェクトタイプ | 必須エージェント | オプション |
|------------------|-----------------|----------|
| 設計・計画 | architect | general |
| 開発・実装 | tester | architect |
| レビュー・監査 | reviewer | fixer |
| フルサイクル | architect + tester + reviewer | doc, fixer |

---

## プロジェクト管理

プロジェクトは `WORKS/{MMDD}{ProjectName}/` 形式で管理する。

### ディレクトリ構造
```
config/projects.yaml       # プロジェクト一覧・ステータス
WORKS/                      # プロジェクトルートディレクトリ
WORKS/{MMDD}{ProjectName}/  # 各プロジェクト
  ├── project.yaml         # プロジェクト詳細
  ├── src/                 # ソースコード
  └── docs/                # 設計書等
```

### Git管理
- `WORKS/` ディレクトリはGit追跡対象外（機密情報を含むため）
- `config/projects.yaml` は一覧情報のみを含み、Git管理対象
- GitHubリポジトリ名は日付を含めない形（例: WORKS/0208NewWorks → GitHub: NewWorks）

---

---

## ファイル命名規則

**重要**: このインフラでは、コンポーネントと非コンポーネントで命名規則を明確に分けています。

### アーキテクチャの分類

| 分類 | ディレクトリ | 役割 | ブラウザ上の存在 |
|------|-------------|------|----------------|
| **コンポーネント** | `components/` | UI部品、DOMにレンダリングされる | ✅ あり |
| **カスタムフック** | `hooks/` | Reactフック、状態管理ロジック | ❌ なし |
| **ユーティリティ** | `lib/` | 関数・型定義・AIプロバイダー | ❌ なし |
| **ストア** | `stores/` | Zustand状態管理 | ❌ なし |
| **ページ/レイアウト** | `app/` | Next.jsルーティング | ✅ あり（規約固定） |

### 命名規則

```
components/  → PascalCase (例: EditableWrapper.tsx)
hooks/       → kebab-case (例: use-auto-save.ts)
lib/         → kebab-case (例: generate-id.ts)
stores/      → kebab-case (例: chat-store.ts)
app/         → Next.js規約 (page.tsx, layout.tsx は固定名)
```

### 理由: data-l属性の視認性

**コンポーネントのみパスカルケース**を採用する理由：

1. **data-l属性での視認性**
   - `data-l="EditableWrapper184"` ← 一目でコンポーネント由来とわかる
   - `data-l="Page97"` ← ページ由来と区別がつく

2. **ダブルクリック選択のしやすさ**
   - `EditableWrapper184` ← ユーザーがダブルクリックで選択しやすい
   - `use-auto-save-42` ← 選択されることはない（DOMに存在しない）

3. **ブラウザ開発者ツールでの確認**
   - 要素を検証 → `data-l` 属性を確認 → 即座にファイルと行番号が特定できる

### 覚え方

```
DOMに見えるもの = PascalCase
DOMに見えないもの = kebab-case
```

---

## data-l属性: ソースロケーションシステム

このインフラでは、**開発環境でのみ**全JSX要素に `data-l` 属性を自動注入しています。

### 技術実装

**Babelカスタムプラグイン** (`babel-plugin-source-locator.js`) を使用：

1. `.babelrc` で開発環境のみプラグイン有効化
2. 全JSX要素のオープニングタグを検出
3. 要素名（ファイル名から生成）+ 行番号を `data-l` 属性として注入
4. 属性は他の属性よりも前に配置（要素名の直後）

```javascript
// babel-plugin-source-locator.js
module.exports = function ({ types: t }) {
  return {
    visitor: {
      JSXOpeningElement(path, state) {
        const filename = state.file.opts.filename;
        const loc = path.node.loc;

        // ファイル名からコンポーネント名を生成
        // editable-wrapper.tsx → EditableWrapper
        const componentName = filename
          .split('/')
          .pop()
          .replace(/\.(tsx?|jsx?)$/, '')
          .split('-')
          .map(word => word.charAt(0).toUpperCase() + word.slice(1))
          .join('');

        // data-l="EditableWrapper184" を注入
        const attr = t.jsxAttribute(
          t.jsxIdentifier("data-l"),
          t.stringLiteral(`${componentName}${loc.start.line}`)
        );

        path.node.attributes.unshift(attr);
      }
    }
  };
};
```

### data-l属性の形式

```
data-l="{コンポーネント名}{行番号}"
```

| 例 | ファイル | 行番号 |
|----|---------|--------|
| `EditableWrapper184` | `EditableWrapper.tsx` | 184 |
| `Page463` | `page.tsx` | 463 |
| `ChatSidebar60` | `ChatSidebar.tsx` | 60 |
| `Layout95` | `layout.tsx` | 95 |

### AIへの指示方法

```
「EditableWrapper184のボタンを削除して」
「Page463の見出しを『新製品』に変更して」
```

data-l値を指定することで、即座にファイルと行番号が特定できます。

---

## 重要なルール

### 1. コード構成
- 巨大なファイルよりも、小さく分割された多数のファイルを優先する
- 高凝集・低結合
- 1ファイルあたり200〜400行が目安、最大800行
- 機能/ドメイン別に整理する

### 2. コードスタイル
- コード、コメント、ドキュメントに絵文字を使用しない
- **常に不変性（Immutability）を維持する** - オブジェクトや配列を直接変更しない
- 本番コードに `console.log` を残さない
- `try/catch` による適切なエラーハンドリング
- Zodなどを用いた入力バリデーション

### 3. a11y（アクセシビリティ）
- **a11yツリー（アクセシビリティツリー）** の考え方を採用
- AIが理解しやすい属性（role, aria-*）を付与
- 要素を「意味のある部品」として扱う

```tsx
// 例: a11y準拠の属性
<div
  data-cpl-id="blk_abc123"
  data-cpl-type="heading"
  role="heading"
  aria-level="2"
  aria-label="ヒーローセクションのメイン見出し"
>
  <h2>Creative Developer</h2>
</div>
```

### 4. テスト規約
- TDD: テストを先に書く
- 最小カバレッジ 80% を維持する
- ユーティリティにはユニットテスト、APIには結合テストを書く

### 5. セキュリティ
- シークレット情報をハードコードしない
- 環境変数を使用する
- すべてのユーザー入力をバリデーションする

---

## エージェント履歴追跡

このインフラでは**マルチエージェントによる並列作業を追跡**するため、コミットメッセージにエージェント名を明記します。

### エージェント作業後の必須コミット

```bash
# Git Aliasが設定済みの場合（推奨）
git ai

# または手動でコミット
git add -A && git commit -m "<エージェント名>: <変更内容の説明>"
```

### コミットが不要な場合
- 単純な説明や質問への回答
- コードの編集を伴わない場合

### コミットが推奨される場合
- コードを生成・編集した場合
- ファイルを作成・削除した場合
- リファクタリングを行った場合

### コミットメッセージの形式

エージェント名をプレフィックスとして使用し、「誰が」作業を行ったかを明確にします。

| エージェントタイプ | プレフィックス | 例 |
|-----------------|---------------|-----|
| Agent Teams | `[name]:`  | `reviewer: コンポーネント実装` |
| 人間 | 名前またはなし | `self: デザイン調整` |

**重要**: エージェント名は、そのエージェントが作業を行ったことを明確にするためのものです。GitのAuthor情報は全て「Claude」になるため、コミットメッセージでの追跡が重要です。

---

## 言語設定

`config/settings.yaml` の `language` で設定（※ 将国風表現を解除する場合）

```yaml
language: standard  # standard（標準）, ja（戦国風）
```

---

## コンテキスト保持の三層モデル

```
Layer 1: Memory MCP（永続・セッション跨ぎ）
  └─ ルール・判断基準・知見

Layer 2: Project（永続・プロジェクト固有）
  └─ config/projects.yaml: プロジェクト一覧
  └─ context/{project}.md: PJ固有の技術知見

Layer 3: Session（揮発・コンテキスト内）
  └─ CLAUDE.md（自動読み込み）
  └─ /clearで全消失、コンパクションでsummary化
```

---

## Summary生成時の必須事項

コンパクション用のsummaryを生成する際は、以下を必ず含めよ：

1. **役割**: チームリーダー（メインエージェント）
2. **主要な禁止事項**: チームメンバーはCLAUDE.mdを読まない
3. **現在のタスクID**: 作業中のcmd_xxx

---

## コンパクション復帰時の必須行動（チームリーダー専用）

コンパクション後は作業前に必ず以下を実行せよ：

### 手順

1. **自分の役割を確認**
   - 自分はチームリーダー（メインエージェント）である

2. **Memory MCP を読む**（推奨）
   ```bash
   mcp__memory__read_graph()
   ```
   - Memory MCPに保存されたルール・コンテキスト・殿の好みを確認
   - 記憶の中に汝の行動を律する掟がある

3. **CLAUDE.md を読む**

4. **TaskList でチーム状況を確認**
   ```python
   TaskList()
   ```
   - 全タスクの状況を把握
   - summaryの「次のステップ」を見てすぐ作業してはならない

### セッション開始とコンパクション復帰の違い

| 種別 | 状態 | 復元方法 |
|------|------|---------|
| **セッション開始** | Claude Codeの新規起動。白紙の状態 | Memory MCP + CLAUDE.md で復元 |
| **コンパクション復帰** | 同一セッション内でコンテキスト圧縮 | summary + TaskList + 必要に応じてMemory MCP |
| **/clear後** | コンテキスト全消去 | Memory MCP（失敗時も継続可） |

### Memory MCP が利用できない場合

Memory MCP は外部サービス依存のため、一時的に利用できない可能性があります。
その場合でも、以下の情報で復帰可能です：

1. **CLAUDE.md**（自動読み込み）- インフラの基本設定
2. **TaskList** - タスク状況の正データ
3. **~/.claude/agents/{name}.md** - チームメンバーの定義

Memory MCP からの復元は「推奨」であり、必須ではありません。

### チームメンバーの復帰

チームメンバー（カスタムエージェント）は、自分の定義ファイル（`~/.claude/agents/{name}.md`）に従って復帰します。

---

## 関連ファイル

- **context/**: Agent Teamsインフラのシステム説明
  - system_architecture.md: システム構造、エージェント定義
  - workflow.md: ワークフロー詳細
  - protocols.md: 通信プロトコル詳細
  - memory_mcp_rules.md: Memory MCP活用ルール
  - voice_input_guide.md: 音声入力ガイド
- **config/**: 設定ファイル
- **bin/**: ユーティリティスクリプト
