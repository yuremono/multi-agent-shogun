# Context ディレクトリ

このディレクトリは、Agent Teamsインフラのシステム説明を管理する場所です。

## ディレクトリの役割

この `context/` ディレクトリは **インフラ（multi-agent-shogun）のシステム説明** を管理します。

- **インフラ用**: システムアーキテクチャ、ワークフロー、通信プロトコル等の説明
- **プロジェクト用**: 各プロジェクト固有の知見は `WORKS/{MMDD}{ProjectName}/context/` に配置

## ファイル構成

```
context/
├── README.md              # このファイル
├── system_architecture.md # Agent Teamsシステムアーキテクチャ
├── workflow.md            # ワークフロー詳細
├── protocols.md           # 通信プロトコル詳細
├── memory_mcp_rules.md    # Memory MCP活用ルール
└── voice_input_guide.md   # 音声入力ガイド
```

## 各ファイルの説明

| ファイル | 内容 |
|---------|------|
| **system_architecture.md** | Agent Teamsのシステム構造、階層、エージェント定義 |
| **workflow.md** | セッション開始・コンパクション復帰の手順、タスク管理 |
| **protocols.md** | TeamCreate, Task, SendMessage等の通信プロトコル |
| **memory_mcp_rules.md** | Memory MCPの保存基準と運用ルール |
| **voice_input_guide.md** | 音声入力誤変換パターンと解釈ガイド |

## プロジェクト固有コンテキスト

各プロジェクト固有の技術知見・注意事項は、プロジェクトディレクトリ内に配置します：

```
WORKS/{MMDD}{ProjectName}/
├── context/
│   └── {project}.md      # プロジェクト固有の技術知見
├── project.yaml          # プロジェクト詳細
├── src/                  # ソースコード
└── docs/                 # 設計書等
```

## 使い方

### インフラの仕組みを知りたい場合

1. `context/system_architecture.md` を読んでシステム全体像を把握
2. `context/workflow.md` を読んで作業手順を理解
3. `context/protocols.md` を読んで通信方法を理解

### 新規プロジェクトを開始する場合

1. `WORKS/{MMDD}{ProjectName}/` を作成
2. `WORKS/{MMDD}{ProjectName}/context/{project}.md` を作成
3. プロジェクト固有の技術知見・注意事項を記載

## プロジェクトコンテキストのテンプレート

```markdown
# {project_id} プロジェクトコンテキスト
最終更新: YYYY-MM-DD

## 基本情報
- **プロジェクトID**: {project_id}
- **正式名称**: {name}
- **パス**: WORKS/{MMDD}{ProjectName}/

## 概要
{プロジェクトの概要を1-2文で}

## 技術スタック
- 言語:
- フレームワーク:
- データベース:

## 重要な決定事項
- {決定1}
- {決定2}

## 注意事項
{プロジェクト固有の注意点}
```

## 更新ルール

- システムに大きな変更があったら即座に更新
- 日付を必ず更新
- 不要になった情報は削除（シンプルに保つ）
