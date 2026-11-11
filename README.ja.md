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

インストール後、GitとJujutsuの個人設定を行います：

```shell
# ユーザー設定スクリプトを実行
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/setup-user.sh)"
```

または、既にリポジトリをクローンしている場合：

```shell
./setup-user.sh
```

以下の情報の入力を求められます：

- GitとJujutsuのコミット用フルネーム
- メールアドレス
- GPGキーID（オプション、コミット署名用）

同じ名前とメールアドレスを両方に保存します。GPGキーを入力すると、Gitの署名とJujutsuの自分のコミットへの署名を有効にし、空欄なら両方の自動署名を無効にします。`jj` が見つからない場合はGitだけを設定するため、Jujutsuのインストール後に再実行してください。

## 更新

インストール済みcheckoutをfast-forwardで更新し、シンボリックリンクと新たに必要になったツールを再同期します：

```shell
~/.dfiles/update.sh
```

`~/.dfiles` に未コミットの変更がある場合やfast-forwardできない場合、更新前に停止します。意図的なローカル変更は先にコミットまたはstashしてください。GPU/CUDA構成も適用する場合は `~/.dfiles/update.sh --gpu` を使用します。

JujutsuとGitを併用するcheckoutでは、`jj git fetch` で取得し、設定済みの `trunk()`（通常は `main@origin`）を更新先に使います。作業コピーが空で競合がなく、親が1つであることを確認し、その親から更新先へfast-forwardできる場合だけ、更新先に新しい空のchangeを作成します。ローカルのコミットが更新先より先に進んでいる場合は、それを保持して設定を再適用します。履歴が分岐している場合は停止します。作業コピーの変更は先に `jj commit` で保存してください。Gitのみのcheckoutでは、upstreamを設定したブランチに切り替えておく必要があります。

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
- `.config/jj/config.toml.template` - 初回インストール時にJujutsuのユーザー設定へコピーするテンプレート
- `setup-user.sh` - 個人設定用インタラクティブスクリプト
- `installer.sh` - メインインストールスクリプト
- `update.sh` - fast-forwardによる安全な更新と設定の再同期
- `uninstaller.sh` - バックアップ付きの対話式削除
- `init.vim` - Vim/Neovim設定とdpp.vimの起動処理
- `.config/nvim/dpp.ts` - dpp.vimのプラグイン定義
- `.config/herdr/config.toml` - `~/.config/herdr/config.toml` と同期するHerdr設定
- `.config/herdr-app/keys.json` - Codex CLIの操作を優先するLinux・Windows共通のキー設定
- `.config/herdr-app/keys.windows.json` - Windows専用の `Ctrl+J` 上書き設定
- `.config/herdr-app/apply-windows.ps1` - バックアップ付きでWindows用設定を反映するスクリプト
- `.config/ghostty/config.ghostty` - `~/.config/ghostty/config.ghostty` と同期するGhostty設定
- `.config/agents/skills.txt` - `~/.agents/skills/` へ復元する外部・ローカルの全Agent Skills一覧
- `.config/agents/skills/` - ローカルスキルと外部スキルへの上書きファイル
- `AGENTS.md` - このリポジトリのコントリビューターガイド
- `.config/.codex/` - `~/.codex/` へ同期されるCodex向け指示書と実行ポリシールール。削除済みの管理対象は `obsolete-paths.txt` に従って除去されます
- `.zshrc` - Prezto使用のZshシェル設定

## アーキテクチャ概要

### 設定ファイル構成

- **Zsh設定**: Preztoフレームワークを使用。`.zshrc`でエイリアスと環境変数を定義
- **Git設定**: `.gitconfig`でGPG署名、エイリアス、Git LFSを設定
- **Jujutsu設定**: 個人用のTOMLファイルに名前・メールアドレス・署名設定を保存し、`.zshrc`でstandard補完を読み込む
- **エディタ設定**: `init.vim`でdpp.vimを起動し、`dpp.ts`からDenops経由でプラグインを定義

### installer.shの動作

1. Zshをインストールして、実行ユーザーの既定のログインシェルに設定
2. dotfilesリポジトリをクローン
3. Prezto（Zshフレームワーク）をインストール
4. 各設定ファイルのシンボリックリンクを作成
5. dpp.vim、Denops、インストーラー/Git拡張をbootstrap
6. 宣言されたAgent Skillsをユーザー共通のスキルディレクトリへ復元
7. 開発ツール（Deno、Node.js、pnpm、Rust、Bun、uv等）を自動インストール

既定シェルの変更は次回のログインまたは新しいターミナルから有効になります。現在のセッションですぐに使う場合は `exec zsh` を実行してください。

### 開発環境

- **JavaScript/TypeScript**: NVM、Node.js、pnpm、Bun、Deno（dpp.vimで必須）
- **Python**: uv（高速パッケージマネージャ）
- **Rust**: rustup、Cargo、cargo-binstall（Jujutsuの導入に必要な場合）
- **バージョン管理**: Git、Jujutsu（`jj`）
- **その他**: Go、Herdr、CUDA（GPU計算）、GitHub CLI
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

# dpp.vimのプラグイン定義を編集
nvim ~/.config/nvim/dpp.ts

# 手動インストール・更新が必要な場合にVim/Neovim内で実行
:DppInstall
:DppUpdate
```

dpp.vimにはDeno 2.3.0以上、denops.vim 8.0以上、および対応エディター（Neovim 0.11.3以上またはVim 9.1.1646以上）が必要です。インストーラーはDenoを導入し、APT版Neovimが古い場合は警告します。

既存環境の更新時、`update.sh`はこのリポジトリが作成した旧symlinkだけを削除します。dppの動作確認後、不要になった`~/.cache/dein`は手動で削除できます。

### Codex CLI

```bash
# インストール済みバージョンを確認
codex --version

# 同期されたエージェント指示書を編集
nvim ~/.codex/AGENTS.md
```

`installer.sh` と `update.sh` は `.config/.codex/rules/*.rules` を `~/.codex/rules/` へコピーします。同名ファイルは更新し、それ以外のルールファイルは保持します。ローカルで保存した承認を含む `default.rules` も保持されます。同期後は Codex を再起動してルールを読み込んでください。

管理対象の `jj.rules` は、[公式の Git 承認設定例](https://learn.chatgpt.com/docs/enterprise/security-cookbook#require-approval-for-sensitive-commands)の区分を参考にしています。`jj status`・`jj log`・`jj diff` などの閲覧はサンドボックス外での実行を許可し、コミット、履歴変更（`restore`・`abandon`・`rebase` など）、リモート操作（`git fetch`・`git push`）、設定変更、外部コマンドの実行は確認対象にします。ブックマークや操作履歴も、閲覧は許可し、変更は確認対象です。Jujutsu は閲覧時にも作業コピーをスナップショットすることがあるため、避けたい場合は `--ignore-working-copy` を使ってください。

このルールはコマンドの接頭辞で判定し、リスクを自動分類するものではありません。`jj.rules` に列挙した一般的な前置オプションには対応し、それ以外のオプション順序や独自エイリアスは通常のサンドボックス・承認設定に従います。別のファイルに包括許可の `prefix_rule(pattern=["jj"], decision="allow")` が保存されている場合は、未対応の形式が許可され続けるため、移行時に削除してください。このルールだけを同期する場合は `cp .config/.codex/rules/jj.rules ~/.codex/rules/jj.rules` を実行し、Codex を再起動します。

### pnpm

nvmで管理するNode.js LTSの導入後、npmを使ってpnpm 11をグローバルインストールします。WSLではWindowsのPATHから継承されたpnpmを無視し、Linux版を導入します。次のコマンドで確認できます：

```bash
pnpm --version
```

### Jujutsu

[公式のインストール・設定手順](https://docs.jj-vcs.dev/latest/install-and-setup/)に従い、Rustの導入後に `cargo binstall --strategies crate-meta-data jj-cli --no-confirm` を実行します。cargo-binstallがなければ、先に `cargo install cargo-binstall --locked` で導入します。`update.sh` の実行時も、既存の `jj` はそのまま使います。

`.config/jj/config.toml.template` は `jj config path --user` が返すパスへコピーします。通常は `~/.config/jj/config.toml` で、`XDG_CONFIG_HOME` にも対応します。既存の設定や複数のパスを使う設定は保持します。個人設定は `jj config set --user` で編集し、リポジトリへのシンボリックリンクにはしません。

```bash
jj --version
./setup-user.sh
jj config edit --user
```

Zshでは補完の初期化後、`source <(jj util completion zsh)` で **standard補完** を読み込みます。新しいシェルを開くか、`source ~/.zshrc` で反映してください。

### Herdr

```bash
# ターミナルマルチプレクサーを起動
herdr

# 公式インストーラーで導入したHerdrを更新
herdr update

# 同期した設定を再読み込み
herdr server reload-config
```

インストーラーはHerdr公式スクリプトを使用して `~/.local/bin/herdr` へ導入し、`.config/herdr/config.toml` を `~/.config/herdr/config.toml` へリンクします。既存の通常ファイルは、リポジトリ内の設定と内容が一致する場合に限りシンボリックリンクへ移行します。

`Ctrl+Tab` で次のタブ、`Ctrl+Shift+Tab` で前のタブへ切り替えます。

`.config/.codex/AGENTS.md` では、TUI 用の `herdr` スキルとデスクトップ用の `herdr-app` スキルで、リポジトリの選択と委任の方針を共通化しています。どちらも稼働中の space と端末のディレクトリで作業先を確認し、マシンや worktree を区別します。サブエージェントは依頼された場合だけ起動し、後片付けは自分で作成したリソースに限ります。継承された ID や UI のフォーカスは、別リポジトリを指す場合があります。

TUI では `--no-focus` を付けて別タブを使います。対応する workspace を一意に特定できない場合は、リポジトリのルートで新規作成し、初期タブを使います。アプリでは画面を切り替えずに作業できるよう、バックグラウンド処理を配置用ラベルのない `hc` 端末で実行します。表示するタブや分割は依頼された場合に作成し、その際に対応する space がなければ依頼の一部として作成します。アプリの端末アドレスとペイン ID は別物で、TUI のコマンド引数も流用しません。

各スキルは、導入済みの `herdr --skill`、`herdr-app --skill`、`hc --skill` で現行の仕様を確認します。アプリ固有のリモート実行、端末の復旧、mod・レイアウト・キー設定は専用の手順を保ち、カスタマイズ時はアプリの設定ディレクトリに生成される説明書と型定義を参照します。ここで追加するのはスキルの対応です。アプリと core は別途導入しておく必要があり、実際の設定は移行しません。

### Herdr app（Linux / Windows）

共通の [`.config/herdr-app/keys.json`](.config/herdr-app/keys.json) は、Codex CLIの操作を優先する設定です。`F1`～`F12`、`Alt+矢印`、`Ctrl+←/→`、`Ctrl+J` を端末内のプログラムへ渡します。Linuxではこのファイルをそのまま使います。Windowsでは [`keys.windows.json`](.config/herdr-app/keys.windows.json) の `terminal.ctrl-j` だけを上書きし、ConPTYを通してControl+Jを保持するため、Windowsのキー押下・解放イベントとして送信します。

Herdrが読み込むのは適用後の `keys.json` です。`keys.windows.json` を置くだけでは自動で統合されません。Herdr appとherdr-coreを導入し、アプリのウィンドウを動かしているOSに合わせて次の手順を実行してください。Windows版アプリからLinuxやWSLへ接続する場合も、Windows用の設定を使います。

#### Linux

リポジトリのルートから共通設定をコピーします。GNU版の `cp --backup=numbered` により、既存ファイルは `keys.json.~1~`、`keys.json.~2~` などの名前で保存されます。`HERDR_APP_HOME` を設定している場合は、その保存先を使います。

```bash
herdr_config_dir="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
mkdir -p "$herdr_config_dir"
cp --backup=numbered .config/herdr-app/keys.json "$herdr_config_dir/keys.json"
herdr-app status
```

#### Windows

リポジトリのルートから、次のコマンドをPowerShellで実行してください。スクリプトが両方のJSONを読み、`Ctrl+J` だけを上書きした `keys.json` を `$env:USERPROFILE\.config\herdr-app` へ保存します。`HERDR_APP_HOME` があればそちらを使います。既存ファイルは置換前にバックアップし、同じ内容なら書き込みを省略します。

```powershell
& .\.config\herdr-app\apply-windows.ps1
herdr-app status
```

保存先を個別に指定する場合は `-ConfigDir <ディレクトリ>` を付けます。リポジトリ内の共通設定と上書き設定は変更しません。元ファイルを編集した後や更新を取得した後は、使うOSのコマンドを再実行してください。`installer.sh`、`update.sh`、`uninstaller.sh` は、これらのHerdr app設定を反映・削除しません。

Herdrは起動中でも `keys.json` を再読み込みします。`herdr-app status` でエラーの有無を確認してください。設定が不正な場合は最後に読み込めた設定が維持され、アプリの設定ディレクトリに `keys.error` が作られます。

| Herdr appの操作 | キー |
|---|---|
| タブ名変更 / スペース名変更 | `Ctrl+Shift+F2` / `Ctrl+Shift+F3` |
| タブ1～9を選択 | `Ctrl+Shift+1`～`9` |
| 前 / 次のエージェントへ移動 | `Alt+Shift+↑` / `Alt+Shift+↓` |
| 左 / 下 / 上 / 右のペインへ移動 | `Alt+H` / `Alt+J` / `Alt+K` / `Alt+L` |
| ショートカット一覧 | `Ctrl+Shift+F1` |
| 拡大 / 縮小 / 倍率リセット | `Alt+=` / `Alt+-` / `Alt+0` |

Herdr app 0.1.15とCodex CLI 0.167.1を対象にしています。Windowsの入力形式は隔離コンソールで確認済みです。Codex画面での実キー操作とLinux版アプリでの動作は未確認のため、反映後に `Ctrl+J` で改行が入り、`F2` でCodexの警告一覧が開くことを確認してください。`keys.json` をカスタマイズすると、Herdrの更新時に新しい既定の割り当てへ自動置換されなくなるため、必要な新規キーは手動で追加します。

### Ghostty

インストーラーは `.config/ghostty/config.ghostty` も `~/.config/ghostty/config.ghostty` へリンクし、既存ファイルを同じ方針で保護します。Ghostty本体はインストールしません。GNOME Terminalのプロファイル `b1dcc9dd-5262-4d8d-a863-c897e6d979b9` から、点滅するブロックカーソル、スクロール動作、システムベル、コマンド終了後に閉じる動作をコピーしています。フォントはHackGen Console NF（13 pt）、初期表示領域はこの環境のGNOME Terminalと同程度の134列 × 34行を目標にしています。`window-height = 34` で実表示が31行になったため、設定値は `window-width = 134`、`window-height = 37` としています。この環境では補正後の実表示が134列 × 34行になることをユーザーが確認済みです。別の環境では補正量が異なる場合があります。配色はGhostty標準のままです。履歴10,000行やスクロールバーの常時表示など、正確に対応する設定がないものはGhostty標準のままにしています。コピー時点の固定値のため、変更するときはリポジトリ内のファイルを編集してください。GTKのウィンドウ装飾により、実際の行・列数が指定した初期サイズとずれる場合があります。

共通指示には会話と作業範囲の方針を置き、日本語の文書執筆に関する詳細は `japanese-tech-writing` に集約しています。`cognitive-rhythm-writing` は必要に応じた文章の緩急の調整、`frontend-design` は画面の設計・実装、`grilling` は依頼された計画の検討インタビューを扱います。スキルの説明は適用する作業を具体的に示し、追加の規範は必要なときに読み込みます。

`frontend-design` は既存のデザイン体系を保ちながら、配色・余白・文字・製品の図解・動きの選び方を示します。描画された画面を確認し、依頼の範囲内で影響の大きい問題から直す手順も含みます。

両方を使う場合、`hallmark` は見た目の方向性とスタイルの既定方針を、`frontend-design` は実装・レスポンシブ対応・アクセシビリティ・動作確認を担当します。質問や設計、レビューを一つの手順にまとめ、ユーザーの要件と既存のデザイン体系を優先します。

文章向けの2つのスキルは、事実と条件を保ちながら主述関係・操作の説明・文のつながりを整えます。編集の判断例を備え、文長や箇条書き率を一律の目標にせず、文脈に応じて表現と構成を選びます。

`jj` スキルは、Jujutsuの作業コピーの変更、履歴の書き換え、競合からの復旧、ブックマーク、Gitリモートを扱います。管理元は `.config/agents/skills/jj/` で、インストーラーが `~/.agents/skills/jj/` へ同期します。実行には既存の `jj` を使用します。

### Agent Skills

管理対象の全Agent Skillsを `.config/agents/skills.txt` に定義します。`installer.sh` と `update.sh` は、インストーラーの `sync_agent_skills` 関数を通じて `~/.agents/skills/` へ復元します。同期は加算型で、一覧にないインストール済みスキルは保持し、未登録のローカルディレクトリはコピーしません。

各行には導入元とスキル名を空白区切りで記載します。導入元がリポジトリならSkills CLIでグローバルにインストールし、`local` なら `.config/agents/skills/<名前>/` をコピーします。どちらの場合も、同名のローカルディレクトリ内のファイルがインストール先のファイルに優先します。空行と `#` で始まる行は無視されます。記載例は次のとおりです。

```text
nutlope/hallmark hallmark
local jj
```

同期対象は外部スキル4件（`hallmark`、`yomiyasu`、`herdr`、`find-skills`）とローカルスキル6件（`cognitive-rhythm-writing`、`frontend-design`、`grilling`、`herdr-app`、`japanese-tech-writing`、`jj`）です。ローカルスキルを追加するには、一覧と同じディレクトリ内に `skills/<名前>/SKILL.md` を作り、`local <名前>` を一覧へ追記します。名前の重複、書式の不備、ローカルディレクトリの `SKILL.md` 欠落がある場合は、スキルのインストールやコピーを始める前に同期を中止します。`npx` がない場合は警告を出して外部スキルの導入を省略し、ローカルファイルのコピーは続けます。

`hallmark` の導入後には `.config/agents/skills/hallmark/` のファイルを上書きコピーします。このディレクトリには、独自に変更した `SKILL.md`、`references/flow.md`、`references/gates.md`、`references/redesign.md`、参照検証スクリプトとそのテスト、配布元のライセンスを保存しています。本文のサイズ制限を守るため、ページ構成の詳細と Picks の出力例は `references/flow.md` に分けています。拡張フィールドは `metadata` 配下に置き、検証スクリプトはこの形式と配布元の version フィールドの両方に対応しています。その他のスクリプト・テーマ・資料は引き続き `nutlope/hallmark` から導入します。この順序でローカルの変更を毎回復元するため、配布元の更新時には互換性を確認してください。

`herdr` の導入後にも `.config/agents/skills/herdr/SKILL.md` を重ね、配布元のリソースを保ちながらローカルの TUI 運用方針を復元します。ローカルの `herdr-app` スキルには、デスクトップと core の操作方針、および必要に応じて読む端末管理・カスタマイズ用の資料を置きます。互換性のないコマンドを混同しないよう、スキルの入口は2つに分けています。

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
- dpp.vimは初回エディター起動時にstateを生成し、`dpp.ts`で定義したプラグインをインストールします
- Codex向け指示書と実行ポリシールールは `.config/.codex/` で管理します。`update.sh` またはインストーラーを実行すると、同期と `obsolete-paths.txt` に記載したパスの除去が行われます
- 全Agent Skillsは `.config/agents/` で管理し、`skills.txt` の一覧から加算型で復元します。`~/.agents` 自体はGit管理しません
- Git LFSが有効化されています（大容量ファイルの取り扱いに対応）

## トラブルシューティング

### プロキシ環境でローカルMCPへの接続に失敗する場合

Codexで `codex_tui` の起動に失敗し、`127.0.0.1` に対するSquidのHTTP 503ページが表示される場合、ローカルへのリクエストがプロキシへ送られています。`.zshenv` は既存の `NO_PROXY` と `no_proxy` の除外先を統合し、両方に `localhost`・`127.0.0.1`・`::1` を追加します。

Codexを終了し、起動元のZshで `source ~/.zshenv` を実行してから、Codexを起動し直してください。起動済みのプロセスには環境変数の変更が反映されません。

### dpp.vimが動作しない場合

1. `deno --version` と `nvim --version`（または `vim --version`）でバージョンを確認
2. `~/.cache/dpp`が書き込み可能で、`~/.cache/dpp/repos/github.com`以下にbootstrap用リポジトリがあることを確認
3. エディターを再起動してstateを再生成後、`:DppInstall`を実行。以後の更新は`:DppUpdate`を使用

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
- エージェント指示書: `.config/.codex/AGENTS.md` から `~/.codex/AGENTS.md` へ同期
- terminal-browserの終了処理: 明示的に残す指示がなければ、最終応答前にその作業で開いたタブとペインを閉じます。作業前から開いていたブラウザやタブは保持します。
- 再利用ワークフロー: `.config/agents/skills.txt` で定義し、`~/.agents/skills/` へ同期

### Agent Skills

- `.config/agents/skills.txt` で定義します。外部スキルは `npx skills add` で導入し、ローカルスキルと上書きファイルは `.config/agents/skills/` からコピーします
- 共通スキルディレクトリ: `~/.agents/skills/`

## ライセンス

このdotfilesは個人使用を想定しており、自由に使用・改変できます。
