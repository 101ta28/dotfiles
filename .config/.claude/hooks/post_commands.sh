#!/bin/bash
# =============================================================================
# Claude Code - Post-Command Hook
# =============================================================================
# このフックは、コマンド実行後に実行され、結果の検証や
# 必要に応じて追加処理を行います。

set -euo pipefail

# 設定ファイルのパス
RULES_FILE="$(dirname "$0")/rules.json"
LOG_FILE="$HOME/.claude/hooks.log"

# ログ関数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] POST_COMMAND: $1" >> "$LOG_FILE"
}

# コマンドの成功/失敗を分析
analyze_command_result() {
    local command="$1"
    local exit_code="$2"
    local output="$3"
    
    if [[ $exit_code -eq 0 ]]; then
        log_message "SUCCESS: Command executed successfully: $command"
        
        # 特定のコマンドの成功後処理
        case "$command" in
            *"git clone"*)
                echo "✅ リポジトリのクローンが完了しました"
                ;;
            *"npm install"*|*"pip install"*)
                echo "✅ パッケージのインストールが完了しました"
                ;;
            *"make"*|*"build"*)
                echo "✅ ビルドが完了しました"
                ;;
        esac
        
    else
        log_message "FAILURE: Command failed with exit code $exit_code: $command"
        
        # エラーの分析と提案
        case "$command" in
            *"git"*)
                echo "❌ Gitコマンドが失敗しました"
                echo "  💡 リポジトリの状態や権限を確認してください"
                ;;
            *"npm"*|*"node"*)
                echo "❌ Node.jsコマンドが失敗しました"
                echo "  💡 package.jsonやnode_modules の状態を確認してください"
                ;;
            *"pip"*|*"python"*)
                echo "❌ Pythonコマンドが失敗しました"
                echo "  💡 仮想環境や依存関係を確認してください"
                ;;
            *"make"*|*"build"*)
                echo "❌ ビルドが失敗しました"
                echo "  💡 依存関係やビルド設定を確認してください"
                ;;
        esac
    fi
}

# セキュリティチェック
security_check() {
    local command="$1"
    local output="$3"
    
    # 機密情報の漏洩チェック
    if echo "$output" | grep -qE "(password|secret|token|key|api_key)" 2>/dev/null; then
        log_message "SECURITY: Potential sensitive information detected in output"
        echo "⚠️  出力に機密情報が含まれている可能性があります"
    fi
    
    # 不審なネットワーク活動の検出
    if echo "$command" | grep -qE "(curl|wget|ssh|ftp)" 2>/dev/null; then
        log_message "SECURITY: Network command executed: $command"
        echo "🔍 ネットワークコマンドが実行されました"
    fi
}

# メイン処理
main() {
    # 引数チェック
    if [[ $# -lt 3 ]]; then
        log_message "WARNING: Insufficient arguments provided, skipping post-processing"
        exit 0
    fi
    
    local command="$1"
    local exit_code="$2"
    local output="$3"
    
    log_message "Post-processing command: $command (exit: $exit_code)"
    
    # コマンド結果の分析
    analyze_command_result "$command" "$exit_code" "$output"
    
    # セキュリティチェック
    security_check "$command" "$exit_code" "$output"
    
    # 統計情報の記録
    {
        echo "STATS: $(date '+%Y-%m-%d %H:%M:%S') | $command | $exit_code"
    } >> "$HOME/.claude/command_stats.log"
    
    exit 0
}

# エラーハンドリング
trap 'log_message "ERROR: Post-command script failed at line $LINENO"' ERR

# メイン実行
main "$@"