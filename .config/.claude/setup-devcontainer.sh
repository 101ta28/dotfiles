#!/bin/bash
# =============================================================================
# Claude Code - Development Container Setup Script
# =============================================================================
# このスクリプトは、プロジェクトディレクトリにClaude Code用の
# 開発コンテナ設定をセットアップします。

set -euo pipefail

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# ヘルプメッセージ
show_help() {
    cat << EOF
Claude Code Development Container Setup

使用方法:
  $(basename "$0") [TARGET_DIR]

引数:
  TARGET_DIR    対象ディレクトリ（省略時は現在のディレクトリ）

オプション:
  -h, --help    このヘルプを表示
  -f, --force   既存の.devcontainerディレクトリを上書き

例:
  # 現在のディレクトリにセットアップ
  $(basename "$0")
  
  # 特定のディレクトリにセットアップ
  $(basename "$0") /path/to/project
  
  # 強制上書きでセットアップ
  $(basename "$0") -f
EOF
}

# メイン処理
main() {
    local target_dir="$PWD"
    local force_overwrite=false
    
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                force_overwrite=true
                shift
                ;;
            -*)
                log_error "未知のオプション: $1"
                show_help
                exit 1
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # ターゲットディレクトリの確認
    if [[ ! -d "$target_dir" ]]; then
        log_error "ディレクトリが存在しません: $target_dir"
        exit 1
    fi
    
    target_dir=$(realpath "$target_dir")
    log_info "セットアップ対象: $target_dir"
    
    # dotfilesの.devcontainerディレクトリのパス
    local source_devcontainer="$HOME/.config/.claude/.devcontainer"
    local target_devcontainer="$target_dir/.devcontainer"
    
    # ソースディレクトリの確認
    if [[ ! -d "$source_devcontainer" ]]; then
        log_error "Claude Code設定が見つかりません: $source_devcontainer"
        log_error "dotfilesが正しくインストールされているか確認してください"
        exit 1
    fi
    
    # 既存の.devcontainerディレクトリの確認
    if [[ -d "$target_devcontainer" ]]; then
        if [[ "$force_overwrite" == false ]]; then
            log_warn "既存の.devcontainerディレクトリが見つかりました"
            read -p "上書きしますか? (y/N): " -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "セットアップをキャンセルしました"
                exit 0
            fi
        fi
        
        log_info "既存の.devcontainerディレクトリを削除中..."
        rm -rf "$target_devcontainer"
    fi
    
    # .devcontainerディレクトリをコピー
    log_info "Claude Code開発コンテナ設定をコピー中..."
    cp -r "$source_devcontainer" "$target_devcontainer"
    
    # 権限設定
    if [[ -f "$target_devcontainer/setup.sh" ]]; then
        chmod +x "$target_devcontainer/setup.sh"
    fi
    if [[ -f "$target_devcontainer/post-create.sh" ]]; then
        chmod +x "$target_devcontainer/post-create.sh"
    fi
    
    log_success "Claude Code開発コンテナの設定が完了しました!"
    
    # 次のステップを表示
    cat << EOF

${GREEN}次のステップ:${NC}
1. VS Codeでプロジェクトを開く:
   ${BLUE}code "$target_dir"${NC}

2. VS Codeでコマンドパレット (Ctrl+Shift+P) を開き、以下を選択:
   ${BLUE}Dev Containers: Reopen in Container${NC}

3. コンテナが起動するまで待機

${YELLOW}注意事項:${NC}
- 初回起動時はイメージのダウンロードに時間がかかる場合があります
- Docker Desktop または Docker Engine が必要です
- VS Code の Remote - Containers 拡張機能が必要です

EOF
}

# エラーハンドリング
trap 'log_error "スクリプトの実行中にエラーが発生しました (line: $LINENO)"' ERR

# メイン実行
main "$@"