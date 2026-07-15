# Dotfiles

開発環境セットアップ用の個人dotfilesです。

[English README is here](./README.md)

## インストール

### 基本インストール（CPU環境）

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)"
```

### GPU/CUDA開発環境インストール

GPU開発とCUDAサポートが必要な場合：

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)" -s --gpu
```

以下がインストールされます：

- NVIDIA Container Toolkit（Docker GPU サポート）
- CUDA Toolkit 12.6

## インストール後の設定

インストール後、個人のGit設定を行う必要があります：

```shell
# ユーザー設定スクリプトを実行
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/setup-user.sh)"
```

または、既にリポジトリをクローンしている場合：

```shell
./setup-user.sh
```

以下の情報の入力を求められます：

- Gitコミット用のフルネーム
- メールアドレス
- GPGキーID（オプション、コミット署名用）

## 更新

インストール済みcheckoutをfast-forwardで更新し、シンボリックリンクと新たに必要になったツールを再同期します：

```shell
~/.dfiles/update.sh
```

`~/.dfiles` に未コミットの変更がある場合やfast-forwardできない場合、更新前に停止します。意図的なローカル変更は先にコミットまたはstashしてください。GPU/CUDA構成も適用する場合は `~/.dfiles/update.sh --gpu` を使用します。

## アンインストール

インストール済みcheckoutから対話式アンインストーラーを実行します：

```shell
~/.dfiles/uninstaller.sh
```

設定をバックアップした後、ツール、リポジトリ、シェル設定を削除するか個別に確認します。

## セキュリティに関する注意事項

⚠️ **重要**: このdotfilesを使用する前に：

1. **設定ファイルを確認**してセキュリティ要件を満たしているか確認する
2. **個人設定をカスタマイズ**する（`.gitconfig`テンプレートを使用）
3. **GPG署名を設定**する（署名コミットを推奨）
4. **インストールされるツールを確認**し、不要なものは削除する

## ファイル構成

- `.gitconfig.template` - プレースホルダー付きGit設定テンプレート
- `setup-user.sh` - 個人設定用インタラクティブスクリプト
- `installer.sh` - メインインストールスクリプト
- `update.sh` - fast-forwardによる安全な更新と設定の再同期
- `uninstaller.sh` - バックアップ付きの対話式削除
- `init.vim` - Vim/Neovim設定 (dein.vimによるプラグイン管理)
- `.config/nvim/dein.toml` - dein.vimのプラグイン定義（即時読み込み）
- `.config/nvim/dein_lazy.toml` - dein.vimのプラグイン定義（遅延読み込み）
- `AGENTS.md` - このリポジトリのコントリビューターガイド
- `.config/.codex/` - `~/.codex/` と同期されるCodex向け指示書
- `.zshrc` - Prezto使用のZshシェル設定

## アーキテクチャ概要

### 設定ファイル構成

- **Zsh設定**: Preztoフレームワークを使用。`.zshrc`でエイリアスと環境変数を定義
- **Git設定**: `.gitconfig`でGPG署名、エイリアス、Git LFSを設定
- **エディタ設定**: `init.vim`でdein.vimによるプラグイン管理（`dein.toml` / `dein_lazy.toml`）

### installer.shの動作

1. dotfilesリポジトリをクローン
2. Prezto（Zshフレームワーク）をインストール
3. 各設定ファイルのシンボリックリンクを作成
4. dein.vimプラグインマネージャをインストール
5. 開発ツール（Node.js、Rust、Bun、uv等）を自動インストール

### 開発環境

- **JavaScript/TypeScript**: NVM、Bun
- **Python**: uv（高速パッケージマネージャ）
- **Rust**: rustup、Cargo
- **その他**: Go、CUDA（GPU計算）、GitHub CLI
- **GPU/CUDA** (オプション): NVIDIA Container Toolkit、CUDA Toolkit 12.6

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

# dein.vimの設定ファイルを編集
nvim ~/.config/nvim/dein.toml

# プラグインは自動的にインストールされます
# 手動でプラグインをインストールする場合（Vim/Neovim内で実行）
:call dein#install()
```

### Codex CLI

```bash
# インストール済みバージョンを確認
codex --version

# 同期されたエージェント指示書を編集
nvim ~/.codex/AGENTS.md
```

### dotfilesの更新

```bash
~/.dfiles/update.sh
```

### dotfilesのアンインストール

```bash
~/.dfiles/uninstaller.sh
```

## GPG設定（オプション）

コミットにGPG署名を有効にするには：

```shell
# 新しいGPGキーを生成
gpg --full-generate-key

# GPGキーを一覧表示してキーIDを取得
gpg --list-secret-keys --keyid-format LONG

# Gitでキーを使用するよう設定
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgSign true
```

## 重要な注意事項

- コミット時は自動的にGPG署名が付与されます（設定している場合）
- `ls`コマンドは`lsd`（Rust製の高機能ls）にエイリアスされています
- 日本語入力にはfcitxが設定されています
- dein.vimは`dein.toml`で定義したプラグインを自動で取得します
- Codex CLIは `.config/.codex/AGENTS.md` を参照します。指示書を更新したい場合はインストーラーを再実行するか、同ファイルを `~/.codex/AGENTS.md` にコピーしてください
- Git LFSが有効化されています（大容量ファイルの取り扱いに対応）

## トラブルシューティング

### dein.vimが動作しない場合

1. プラグイン情報を更新：`:call dein#update()`
2. `~/.cache/dein`が書き込み可能か確認
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

## AIツール連携

### Codex CLI
- `bun install -g @openai/codex` でインストールされます
- 設定ディレクトリ: `~/.codex/`
- エージェント指示書: `~/.codex/AGENTS.md`（本リポジトリの `AGENTS.md` から同期）

## ライセンス

このdotfilesは個人使用を想定しており、自由に使用・改変できます。
