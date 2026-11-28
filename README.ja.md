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

`~/.dfiles` に未コミットの変更がある場合やfast-forwardできない場合、更新前に停止します。意図的なローカル変更は先にコミットまたはstashしてください。

通常のインストール・更新では、GPU/CUDAツールの導入やCUDA用の環境変数の追加は行いません。`~/.dfiles/update.sh --gpu` を実行すると、オプションのツールを導入し、`~/.zshrc.gpu` へのリンクを作成します。このファイルがある場合だけCUDAのパスを追加します。既定の参照先は `/usr/local/cuda` です（変更する場合は `.zshrc` を読み込む前に `CUDA_PATH` を設定）。その後の通常更新でも、有効にした設定と導入済みのGPU/CUDAツールは維持します。

従来のCUDA 12.9のパスを無条件に追加する設定は削除しました。引き続きこのdotfilesでCUDAのパスを設定する場合は、一度 `--gpu` を付けて実行してください。古いシェルのパスを引き継がないよう、新しいログインセッションで反映を確認してください。

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
- `.config/herdr-app/apply-windows.ps1` - バックアップ付きでWindows用設定を反映するスクリプト
- `.config/ghostty/config.ghostty` - `~/.config/ghostty/config.ghostty` と同期するGhostty設定
- `.config/agents/skills.txt` - `~/.agents/skills/` へ復元する外部・ローカルの全Agent Skills一覧
- `.config/agents/skills/` - ローカルスキルと外部スキルへの上書きファイル
- `AGENTS.md` - このリポジトリのコントリビューターガイド
- `.config/.codex/` - `~/.codex/` へ同期する Codex の設定、指示書、実行ポリシールール。同期時に削除する古いファイルは `obsolete-paths.txt` に記載されています
- `.zshrc` - Prezto使用のZshシェル設定
- `.zshrc.gpu` - `--gpu` を指定してインストール・更新した場合だけリンクするCUDAのパス設定

## アーキテクチャ概要

### 設定ファイル構成

- **Zsh設定**: Preztoフレームワークを使用。`.zshrc`でエイリアスと環境変数を定義
- **Git設定**: `.gitconfig`でGPG署名、エイリアス、Git LFSを設定
- **Jujutsu設定**: 個人用のTOMLファイルに名前・メールアドレス・署名設定を保存し、`.zshrc`で標準補完と動的補完を読み込む
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
- **ブラウザーツール**: terminal-browser、agent-browser（ブラウザー本体とLinux用ライブラリを含む）
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

`installer.sh` と `update.sh` は、`.config/.codex/config.toml` にある項目を `~/.codex/config.toml` に反映します。初回は `uv` が TOML ライブラリの `tomlkit` を取得します。現在の同期対象は `tui.status_line` です。更新するたびに、権限と承認モードを含む表示項目の一覧を適用します。キー割り当てなどの個人設定は保持します。

両スクリプトは `.config/.codex/rules/*.rules` を `~/.codex/rules/` へコピーします。同名ファイルは更新し、それ以外のルールファイルは保持します。ローカルで保存した承認を含む `default.rules` も保持されます。同期後は Codex を再起動して設定とルールを読み込んでください。

管理対象の `jj.rules` は、[公式の Git 承認設定例](https://learn.chatgpt.com/docs/enterprise/security-cookbook#require-approval-for-sensitive-commands)の区分を参考にしています。`jj status`・`jj log`・`jj diff` などの閲覧はサンドボックス外での実行を許可し、コミット、履歴変更（`restore`・`abandon`・`rebase` など）、リモート操作（`git fetch`・`git push`）、設定変更、外部コマンドの実行は確認対象にします。ブックマークや操作履歴も、閲覧は許可し、変更は確認対象です。Jujutsu は閲覧時にも作業コピーをスナップショットすることがあるため、避けたい場合は `--ignore-working-copy` を使ってください。

このルールはコマンドの接頭辞で判定し、リスクを自動分類するものではありません。`jj.rules` に列挙した一般的な前置オプションには対応し、それ以外のオプション順序や独自エイリアスは通常のサンドボックス・承認設定に従います。別のファイルに包括許可の `prefix_rule(pattern=["jj"], decision="allow")` が保存されている場合は、未対応の形式が許可され続けるため、移行時に削除してください。このルールだけを同期する場合は `cp .config/.codex/rules/jj.rules ~/.codex/rules/jj.rules` を実行し、Codex を再起動します。

`agent-browser.rules` は、Codex が `agent-browser-inspect` で行う閲覧を確認なしで許可します。たとえば `agent-browser-inspect open https://example.com` でページを開き、`agent-browser-inspect snapshot -i` で操作可能な要素を一覧できます。本文の取得、要素の状態確認、読み込み待ち、一時ファイルへのスクリーンショット保存にも対応します。セッションを指定するには `--session NAME`、結果を JSON で取得するには `--json` を使います。

クリック、フォーム入力、アップロード、JavaScript 実行、保存した認証情報へのアクセスなどで `agent-browser` を直接使うと、Codex が実行前に確認します。`agent-browser` は閲覧コマンドの後ろにも `--config` などの起動オプションを指定できるため、`agent-browser-inspect` はすべての引数を検査します。インストーラーはこのコマンドを `~/.local/bin` に配置し、ルールと利用手順を Codex に同期します。

管理対象の `herdr-app.rules` は、`hc`・`herdr-app`・`herdr-app.exe` の全サブコマンドを許可します。端末でのコマンド実行やアプリの変更操作も含みます。このルールだけを同期する場合は `cp .config/.codex/rules/herdr-app.rules ~/.codex/rules/herdr-app.rules` を実行し、Codex を再起動します。

Codex は Herdr コマンドを単独で実行し、返ってきた出力から必要な項目を取り出します。たとえば、端末の作業ディレクトリは `hc get <id>` が返す JSON の `foreground.cwd` で確認します。`hc get <id> | jq .foreground.cwd` のようにパイプでつなぐと、Codex は `jq` を個別に判定するため、承認を求めることがあります。

### pnpm

nvmで管理するNode.js LTSの導入後、npmを使ってpnpm 11をグローバルインストールします。WSLではWindowsのPATHから継承されたpnpmを無視し、Linux版を導入します。次のコマンドで確認できます：

```bash
pnpm --version
```

### Jujutsu

`jj` が未導入の場合、インストーラーは `cargo binstall --strategies crate-meta-data jj-cli --no-confirm` で導入します。cargo-binstall が必要な場合は、先に `cargo install cargo-binstall --locked` で導入します。[Jujutsu 公式のインストール手順](https://docs.jj-vcs.dev/latest/install-and-setup/)

`update.sh` は実行のたびに、`PATH` で選ばれた `jj` を確認します。その実行ファイルが crates.io の安定版 `jj-cli` として Cargo に登録されていれば、cargo-binstall が新版を確認し、同じインストール先に更新します。OS のパッケージ、手動配置のバイナリ、Git やローカルソースからのビルドは、それぞれの方法で更新します。インストーラーを直接実行した場合は、既定で導入済みの `jj` を引き続き使います。

`.config/jj/config.toml.template` は `jj config path --user` が返すパスへコピーします。通常は `~/.config/jj/config.toml` で、`XDG_CONFIG_HOME` にも対応します。既存の設定や複数のパスを使う設定は保持します。個人設定は `jj config set --user` で編集し、リポジトリへのシンボリックリンクにはしません。

```bash
jj --version
./setup-user.sh
jj config edit --user
```

Zshでは補完の初期化後、`source <(jj util completion zsh)` で標準補完を、続けて `source <(COMPLETE=zsh jj)` で動的補完を読み込みます。新しいシェルを開くか、`source ~/.zshrc` で反映してください。

### Herdr

```bash
# ターミナルマルチプレクサーを起動
herdr

# 公式インストーラーで導入したHerdrを更新
herdr update

# 同期した設定を再読み込み
herdr server reload-config
```

インストーラーは公式スクリプトを使って Herdr を `~/.local/bin/herdr` に導入します。`installer.sh` と `update.sh` は、TUI が読み込む設定ファイルをリポジトリの `.config/herdr/config.toml` へのリンクにします。既定の配置先は `~/.config/herdr/config.toml` です。`XDG_CONFIG_HOME` で設定ディレクトリを、`HERDR_CONFIG_PATH` でファイルのパスを指定でき、後者が優先されます。既存の設定を置き換えるときは、同じディレクトリに `config.toml.~1~` などの連番で保存します。起動中の TUI に反映するには `herdr server reload-config` を実行してください。

`Ctrl+Tab` で次のタブ、`Ctrl+Shift+Tab` で前のタブへ切り替えます。

`.config/.codex/AGENTS.md` では、TUI 用の `herdr` スキルとデスクトップ用の `herdr-app` スキルで、リポジトリの選択と委任の方針を共通化しています。どちらも稼働中の space と端末のディレクトリで作業先を確認し、マシンや worktree を区別します。サブエージェントは依頼された場合だけ起動し、後片付けは自分で作成したリソースに限ります。継承された ID や UI のフォーカスは、別リポジトリを指す場合があります。

短いコマンドや準備はその場で実行します。別端末が必要な場合、TUI では `--no-focus` を付けて別タブを使い、対応する workspace を一意に特定できなければリポジトリのルートで新規作成して初期タブを使います。

アプリでは、開発サーバーやログなど並べて確認する関連作業に別ペインを使います。ブラウザー本体のダウンロード、ビルド、テストなど、独立して進捗を見る作業や広い画面が必要な作業には名前付きの別タブを使います。作業に必要なタブ・ペインと、不足するリポジトリ用 space は、毎回の確認なしで作成します。アプリ 0.1.16 の `space.new` と `tab.new` では `--focus false` で現在の選択を保てます。処理は選んだタブ・ペインの端末内で実行し、ラベルなしの `hc run --bg` は非表示実行の指定がある場合や core だけの環境に限定します。終了通知だけではペインが作られたとは判断しません。アプリの端末アドレスとペイン ID は別物で、TUI のコマンド引数も流用しません。

各スキルは、導入済みの `herdr --skill`、`herdr-app --skill`、`hc --skill` で現行の仕様を確認します。アプリ固有のリモート実行、端末の復旧、mod・レイアウト・キー設定は専用の手順を保ち、カスタマイズ時はアプリの設定ディレクトリに生成される説明書と型定義を参照します。ここで追加するのはスキルの対応です。アプリと core は別途導入しておく必要があり、実際の設定は移行しません。

### Herdr app（Linux / Windows）

共通の [`.config/herdr-app/keys.json`](.config/herdr-app/keys.json) は、`F1`～`F12`、`Alt+矢印`、`Ctrl+←/→` を端末内のプログラムへ渡します。Herdr のキー設定は、アプリのウィンドウを開く OS に適用します。Windows 版の Herdr から WSL を使う場合も、Windows 側に適用してください。

Codex CLI 0.172.0 で権限モードを切り替えるには、**Codex を起動する OS** のユーザー設定に次のキーを追加します。設定ファイルは Windows では `%USERPROFILE%\.codex\config.toml`、Linux・WSL では `~/.codex/config.toml` です。同じテーブルがすでにある場合は、その中の項目を編集してください。改行は既定の割り当てから `Ctrl+J` だけを外しています。

```toml
[tui.keymap.chat]
next_permission_mode = "f6"
previous_permission_mode = "f5"

[tui.keymap.editor]
insert_newline = ["ctrl-m", "enter", "shift-enter", "alt-enter"]
```

Codex を再起動してください。チャット入力欄で `F6` を押すと次の権限モードに、`F5` を押すと前のモードに切り替わります。`/permissions` で現在のモードを確認し、`Esc` で入力欄に戻れます。

#### Linux

`installer.sh` と `update.sh` は、アプリの共通キー設定も `~/.config/herdr-app/keys.json` にコピーします。`HERDR_APP_HOME` を設定した場合は、そのディレクトリを使います。内容が異なるときは、元のファイルを同じディレクトリに `keys.json.~1~`、`keys.json.~2~` のような連番で保存します。Herdr の設定2ファイルだけを同期する場合は、リポジトリのルートで次のコマンドを実行してください。

```bash
bash sync-herdr.sh
```

#### Windows

リポジトリのルートから、次のコマンドを PowerShell で実行してください。スクリプトは共通の `keys.json` を `$env:USERPROFILE\.config\herdr-app` へコピーします。`HERDR_APP_HOME` があればそちらを使います。既存ファイルは置換前にバックアップし、同じ内容なら書き込みを省略します。

```powershell
& .\.config\herdr-app\apply-windows.ps1
herdr-app status
```

保存先を個別に指定する場合は `-ConfigDir <ディレクトリ>` を付けます。Windows 版の Herdr を使う場合は、共通のキー設定を更新した後にこの PowerShell コマンドを再実行してください。Windows 版のウィンドウで WSL の端末を使う場合も同じです。

Herdrは起動中でも `keys.json` を再読み込みします。`herdr-app status` でエラーの有無を確認してください。設定が不正な場合は最後に読み込めた設定が維持され、アプリの設定ディレクトリに `keys.error` が作られます。

| Herdr appの操作 | キー |
|---|---|
| タブ名変更 / スペース名変更 | `Ctrl+Shift+F2` / `Ctrl+Shift+F3` |
| タブ1～9を選択 | `Ctrl+Shift+1`～`9` |
| 前 / 次のエージェントへ移動 | `Alt+Shift+↑` / `Alt+Shift+↓` |
| 左 / 下 / 上 / 右のペインへ移動 | `Alt+H` / `Alt+J` / `Alt+K` / `Alt+L` |
| ショートカット一覧 | `Ctrl+Shift+F1` |
| 拡大 / 縮小 / 倍率リセット | `Alt+=` / `Alt+-` / `Alt+0` |

Herdr は更新時にカスタマイズ済みの `keys.json` を保持します。新しい既定のショートカットが必要になったら、手動で追加してください。

### Ghostty

インストーラーは `.config/ghostty/config.ghostty` も `~/.config/ghostty/config.ghostty` へリンクし、既存ファイルを同じ方針で保護します。Ghostty本体はインストールしません。GNOME Terminalのプロファイル `b1dcc9dd-5262-4d8d-a863-c897e6d979b9` から、点滅するブロックカーソル、スクロール動作、システムベル、コマンド終了後に閉じる動作をコピーしています。フォントはHackGen Console NF（13 pt）、初期表示領域はこの環境のGNOME Terminalと同程度の134列 × 34行を目標にしています。`window-height = 34` で実表示が31行になったため、設定値は `window-width = 134`、`window-height = 37` としています。この環境では補正後の実表示が134列 × 34行になることをユーザーが確認済みです。別の環境では補正量が異なる場合があります。配色はGhostty標準のままです。履歴10,000行やスクロールバーの常時表示など、正確に対応する設定がないものはGhostty標準のままにしています。コピー時点の固定値のため、変更するときはリポジトリ内のファイルを編集してください。GTKのウィンドウ装飾により、実際の行・列数が指定した初期サイズとずれる場合があります。

共通指示には会話と作業範囲の方針を置き、日本語の文書執筆に関する詳細は `japanese-tech-writing` に集約しています。`cognitive-rhythm-writing` は必要に応じた文章の緩急の調整、`frontend-design` は画面の設計・実装、`grilling` は依頼された計画の検討インタビューを扱います。スキルの説明は適用する作業を具体的に示し、追加の規範は必要なときに読み込みます。

`frontend-design` は既存のデザイン体系を保ちます。新しい画面では、利用者が最初に何を判断・操作するかに合わせて、どの情報を目立たせるかを決めます。既存の画面では、どこがその作業を難しくしているかを特定します。修正前後で同じ内容・状態を表示し、狭い画面と広い画面の両方で改善を確かめます。

併用する場合は、`hallmark` で見た目の方向性を決め、`frontend-design` で実装、アクセシビリティ、表示と操作を確認します。どちらも依頼内容と既存のデザイン体系に従います。Hallmark は、ページの制作に Inspo を使う指定がある場合にその成果物を使います。Together AI によるデザイン案の画像生成は、その作業での利用が承認され、API キーがある場合に行います。

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
- `.config/agents/skills.txt` に記載したAgent Skillsは `.config/agents/` で管理し、加算型で復元します。`~/.agents` 自体はGit管理しません。terminal-browserの同梱スキルは公式のセットアップ処理が別途導入します
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
- ブラウザーの使い分け: ユーザーとページを確認しながら進める場合や、ユーザーがページを操作する場合は `terminal-browser`、エージェント内で完結する作業は `agent-browser` を使います。画面共有が不要なら `agent-browser` を基本とし、ユーザーの明示的な指定を優先します。途中でユーザーの確認や操作が必要になった場合は `terminal-browser` に切り替えます。
- terminal-browserの終了処理: 明示的に残す指示がなければ、最終応答前にその作業で開いたタブとペインを閉じます。作業前から開いていたブラウザやタブは保持します。
- 再利用ワークフロー: `.config/agents/skills.txt` で定義し、`~/.agents/skills/` へ同期

### Agent Skills

- `.config/agents/skills.txt` で定義します。外部スキルは `npx skills add` で導入し、ローカルスキルと上書きファイルは `.config/agents/skills/` からコピーします
- 共通スキルディレクトリ: `~/.agents/skills/`
- `agent-browser` スキルは `vercel-labs/agent-browser` から復元します。`terminal-browser` の同梱スキルは、この一覧とは別に公式のセットアップ処理が導入します。

### ブラウザーツール

通常のインストールと `update.sh` で、未導入の両ツールをインストールします。

- [agent-browser](https://github.com/vercel-labs/agent-browser): `npm install --global agent-browser` の後に `agent-browser install --with-deps` を実行し、ブラウザー本体とLinux用ライブラリを導入します。CLIが導入済みでも後者は実行するため、途中で失敗したブラウザーのダウンロードを再試行できます。
- [terminal-browser](https://terminal-browser.com/): 公式の `https://terminal-browser.sh/install` スクリプトでCLIと同梱ブラウザーを導入します。セットアップでスキル導入や端末連携の設定を求められた場合は、スキルの導入に同意すると利用できます。必要に応じて `terminal-browser setup` で再設定できます。CLIの配置先（`${XDG_BIN_HOME:-$HOME/.local/bin}`）はインストーラー実行中のPATHに追加します。

ブラウザーのバイナリーをダウンロードし、Linux用ライブラリやterminal-browserのサンドボックス設定には `sudo` を使う場合があります。既存のCLIはそのまま利用します。terminal-browserの画面表示にはkitty graphics protocol対応の端末が必要です。両ツールの使い分けは上記のCodex向け指示に従います。

## ライセンス

このdotfilesは個人使用を想定しており、自由に使用・改変できます。
