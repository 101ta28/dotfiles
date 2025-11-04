# Check Tools Command

**ツール確認**: dotfiles環境のツールとバージョンを確認し、問題を診断します。

## Arguments

#$ARGUMENTS

## Instructions

dotfiles環境で使用している全てのツールの状態を確認し、問題があれば解決策を提示してください：

### 1. 基本ツールの確認

#### シェル環境

```bash
# Zsh + Prezto + Powerlevel10k
echo "Shell: $SHELL"
zsh --version
echo "Prezto path: ${ZDOTDIR:-$HOME}/.zprezto"
ls -la ~/.zprezto 2>/dev/null || echo "Prezto not found"
echo "Powerlevel10k theme check:"
ls -la ~/.powerlevel10k 2>/dev/null || echo "Powerlevel10k not found"
```

#### 現代的なツール

```bash
# Rust製ツール
lsd --version 2>/dev/null || echo "lsd not installed"
rg --version 2>/dev/null || echo "ripgrep not installed"

# Python環境
uv --version 2>/dev/null || echo "uv not installed"
python3 --version

# Node.js環境
bun --version 2>/dev/null || echo "bun not installed"
node --version 2>/dev/null || echo "Node.js not installed"

# その他のツール
deno --version 2>/dev/null || echo "deno not installed"
gh --version 2>/dev/null || echo "GitHub CLI not installed"
codex --version 2>/dev/null || echo "codex not installed"
```

### 2. エディタ環境の確認

#### Neovim + dein.vim

```bash
# Neovim
nvim --version | head -1

# dein.vim設定の確認
ls -la ~/.cache/dein/repos/github.com/Shougo/dein.vim 2>/dev/null || echo "dein.vim not found"
ls -la ~/.config/nvim/ 2>/dev/null || echo "Neovim config not found"
```

### 3. Git設定の確認

```bash
# Git設定
git --version
git config --get user.name
git config --get user.email
git config --get commit.gpgsign
git config --get init.defaultBranch
```

### 4. Claude Code設定の確認

```bash
# Claude Code関連
claude --version 2>/dev/null || echo "Claude Code not installed"
ls -la ~/.config/.claude/ 2>/dev/null || echo "Claude config not found"
ls -la ~/.config/.claude/hooks/ 2>/dev/null || echo "Claude hooks not found"
```

### 5. 開発コンテナの確認

```bash
# Docker環境
docker --version 2>/dev/null || echo "Docker not installed"
ls -la ~/.config/.claude/.devcontainer/ 2>/dev/null || echo "Devcontainer config not found"
```

### 6. ツール診断レポート

確認完了後、以下の形式でレポートしてください：

```
## 🔍 ツール診断レポート

### ✅ 正常に動作しているツール
- Zsh: [バージョン]
- Prezto: [状態]
- Powerlevel10k: [状態]
- lsd: [バージョン]
- uv: [バージョン]
- bun: [バージョン]
- Neovim: [バージョン]
- dein.vim: [状態]
- codex: [状態]

### ❌ 問題が発見されたツール
- [ツール名]: [問題の詳細]
- [ツール名]: [問題の詳細]

### ⚠️ 未インストールのツール
- [ツール名]: [インストール方法]
- [ツール名]: [インストール方法]

### 🔧 推奨される修正コマンド
```bash
# 例：不足しているツールのインストール
curl -fsSL https://bun.sh/install | bash
cargo install lsd
uv --version || curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 📋 設定ファイルの状態

- .zshrc: [状態]
- .gitconfig: [状態]
- init.vim: [状態]
- .zpreztorc: [状態]
- Claude hooks: [状態]

### 🐳 開発コンテナ環境

- Docker: [状態]
- Devcontainer設定: [状態]
- VS Code拡張: [状態]

### 💡 最適化提案

- [パフォーマンス改善案]
- [設定の最適化案]
- [不要なツールの削除提案]

### 📝 次のアクション

1. [優先度高: 修正すべき問題]
2. [優先度中: 改善すべき項目]
3. [優先度低: 最適化案]

```

### 7. 自動修復（オプション）
問題が発見された場合、可能であれば自動修復コマンドを提案してください：

```bash
#!/bin/bash
# 自動修復スクリプト例

# bunのインストール
if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
fi

# lsdのインストール
if ! command -v lsd >/dev/null 2>&1; then
    cargo install lsd
fi

# uvのインストール
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
```

このコマンドを定期的に実行して、dotfiles環境の健全性を維持してください。
