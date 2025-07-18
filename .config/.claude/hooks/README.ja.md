# Claude Code Custom Hooks

このディレクトリには、Claude Codeの動作を制御するカスタムフックが含まれています。

## 概要

これらのフックは、AIが不適切な提案や危険なコマンドを実行することを防ぐためのセーフティネットとして機能します。

## ファイル構成

### `rules.json`

- NG Word集と制限されたコマンドのルール定義
- JSON形式で設定を管理

### `stop_words.sh`

- AIの応答に不適切なワードが含まれているかチェック
- 推測や不確定な提案を検出

### `pre_commands.sh`

- コマンド実行前に危険性をチェック
- 制限されたコマンドの実行を阻止

### `post_commands.sh`

- コマンド実行後の結果を分析
- セキュリティチェックと統計記録

## 使用方法

### 1. 実行権限の付与

```bash
chmod +x ~/.claude/hooks/*.sh
```

### 2. Claude Codeでの自動実行

Claude Codeは以下のタイミングで自動的にフックを実行します：

- **stop_words.sh**: AI応答生成時
- **pre_commands.sh**: コマンド実行前
- **post_commands.sh**: コマンド実行後

### 3. 手動実行（テスト用）

```bash
# NG Wordチェック
~/.claude/hooks/stop_words.sh "これは代替案として提案します"

# コマンドチェック
~/.claude/hooks/pre_commands.sh "curl https://example.com"

# 実行後処理
~/.claude/hooks/post_commands.sh "git clone repo" 0 "クローン完了"
```

## ログ

- `~/.claude/hooks.log`: フックの実行ログ
- `~/.claude/command_stats.log`: コマンド実行統計

## カスタマイズ

### NG Wordの追加

`rules.json`の`ngWords.words`配列に新しいワードを追加：

```json
{
  "ngWords": {
    "words": [
      "はず",
      "代わり",
      "新しいワード"
    ]
  }
}
```

### 制限コマンドの追加

`rules.json`の`restrictedCommands.commands`オブジェクトに新しいコマンドを追加：

```json
{
  "restrictedCommands": {
    "commands": {
      "dangerous-command": {
        "blocked": true,
        "severity": "high",
        "reason": "危険なコマンド",
        "alternatives": ["安全な代替案"]
      }
    }
  }
}
```

### 危険なコマンドパターンの追加

`rules.json`の`dangerousCommands.patterns`配列に新しいパターンを追加：

```json
{
  "dangerousCommands": {
    "patterns": [
      {
        "pattern": "dangerous-pattern",
        "severity": "critical",
        "reason": "システム破壊の可能性",
        "alternatives": ["安全な代替方法"]
      }
    ]
  }
}
```

## トラブルシューティング

### フックが実行されない場合

1. 実行権限を確認
2. ファイルパスを確認
3. ログファイルを確認

### 誤検出が多い場合

1. `rules.json`のルールを調整
2. 特定のパターンを許可リストに追加
3. フックスクリプトの条件を調整

## セキュリティ注意事項

- フックスクリプトは重要なセキュリティ機能です
- 不用意に無効化しないでください
- 定期的にルールを見直してください
