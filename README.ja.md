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
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)" -s -- --gpu
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
- `init.vim` - Vim/Neovim設定
- `.zshrc` - Prezto使用のZshシェル設定

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
- **その他**: Go、GitHub CLI
- **GPU/CUDA** (オプション): NVIDIA Container Toolkit, CUDA Toolkit

## よく使うコマンド

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
- dpp.vimはDeno 1.45+が必要です（installer.shで自動インストール）

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

## ライセンス

このdotfilesは個人使用を想定しており、自由に使用・改変できます。
