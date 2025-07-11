# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

これは個人用のdotfilesリポジトリです。各種開発ツールとシェル環境の設定を管理しています。

## よく使うコマンド

### 初期セットアップ
```bash
# dotfilesのインストール（新規環境で実行）
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)"
```

### Vim/Neovim関連
```bash
# Neovimでinit.vimを編集
nvim ~/.config/nvim/init.vim

# dpp.vimの設定ファイルを編集
nvim ~/.config/nvim/dpp.ts

# プラグインは自動的にインストールされます
# 手動でプラグインをインストールする場合（Vim/Neovim内で実行）
:call dpp#install()
```

### dotfilesの更新
```bash
# 変更をコミット（GPG署名付き）
git add .
git cm -m "メッセージ"  # cmはcommitのエイリアス

# リモートにプッシュ
git push origin main
```

## アーキテクチャ概要

### 設定ファイル構成
- **Zsh設定**: Preztoフレームワークを使用。`.zshrc`でエイリアスと環境変数を定義
- **Git設定**: `.gitconfig`でGPG署名、エイリアス、Git LFSを設定
- **エディタ設定**: `init.vim`でdpp.vimによるプラグイン管理（TypeScript設定: `.config/nvim/dpp.ts`）

### installer.shの動作
1. dotfilesリポジトリをクローン
2. Prezto（Zshフレームワーク）をインストール
3. 各設定ファイルのシンボリックリンクを作成
4. dpp.vim、denops.vim、dpp-ext-installerをインストール
5. 開発ツール（Node.js、Rust、Bun、uv、Deno等）を自動インストール

### 開発環境
- **JavaScript/TypeScript**: NVM、Bun、Deno
- **Python**: uv（高速パッケージマネージャ）
- **Rust**: rustup、Cargo
- **その他**: Go、CUDA（GPU計算）、GitHub CLI

## 重要な注意事項

- コミット時は自動的にGPG署名が付与されます
- `ls`コマンドは`lsd`（Rust製の高機能ls）にエイリアスされています
- 日本語入力にはfcitxが設定されています
- dpp.vimはDeno 1.45+が必要です（installer.shで自動インストール）