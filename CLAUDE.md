# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

これは個人用のdotfilesリポジトリです。各種開発ツールとシェル環境の設定を管理しています。

## よく使うコマンド

### 初期セットアップ
```bash
# dotfilesのインストール（新規環境で実行）
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)"

# GPU/CUDA開発環境を含むインストール
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)" -s -- --gpu
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
- **GPU/CUDA** (オプション): NVIDIA Container Toolkit、CUDA Toolkit 12.6

## ファイル構成

- `.gitconfig.template` - プレースホルダー付きGit設定テンプレート
- `setup-user.sh` - 個人設定用インタラクティブスクリプト
- `installer.sh` - メインインストールスクリプト
- `init.vim` - Vim/Neovim設定（dpp.vimによるプラグイン管理）
- `.config/nvim/dpp.ts` - dpp.vimのTypeScript設定ファイル
- `.zshrc` - Prezto使用のZshシェル設定
- `CLAUDE.md` - このファイル（AI向け指示書）

## 重要な注意事項

- コミット時は自動的にGPG署名が付与されます（設定している場合）
- `ls`コマンドは`lsd`（Rust製の高機能ls）にエイリアスされています
- 日本語入力にはfcitxが設定されています
- dpp.vimはDeno 1.45+が必要です（installer.shで自動インストール）
- Git LFSが有効化されています（大容量ファイルの取り扱いに対応）

## インストール後の設定

個人のGit設定を行うには：

```bash
# ユーザー設定スクリプトを実行
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/setup-user.sh)"
```

以下の情報の入力を求められます：
- Gitコミット用のフルネーム
- メールアドレス
- GPGキーID（オプション、コミット署名用）

## トラブルシューティング

### dpp.vimが動作しない場合
1. Denoがインストールされているか確認：`deno --version`
2. Denoのバージョンが1.45以上であることを確認
3. Vim/Neovimを再起動

### GPG署名でエラーが発生する場合
1. GPGキーが正しく設定されているか確認
2. GPG署名を一時的に無効化：`git config --global commit.gpgSign false`
3. setup-user.shを再実行して設定を見直す

### GPU/CUDA関連の問題
1. NVIDIA ドライバーが正しくインストールされているか確認：`nvidia-smi`
2. CUDA Toolkitのインストール確認：`nvcc --version`
3. システムの再起動が必要な場合があります
4. Ubuntu 22.04以外のバージョンでは、CUDAインストールスクリプトの調整が必要な場合があります