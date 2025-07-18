#!/bin/bash
# =============================================================================
# Claude Code - Pre-Command Hook
# =============================================================================
# このフックは、危険なコマンドや制限されたコマンドの実行前に実行され、
# rules.jsonを参照して実行を阻止します。

set -euo pipefail

# 設定ファイルのパス
RULES_FILE="$(dirname "$0")/rules.json"
LOG_FILE="$HOME/.claude/hooks.log"

# ログ関数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PRE_COMMAND: $1" >> "$LOG_FILE"
}

# JSONからデータを取得する関数群
get_dangerous_patterns() {
    if command -v jq >/dev/null 2>&1; then
        jq -r '.dangerousCommands.patterns[].pattern' "$RULES_FILE" 2>/dev/null || echo ""
    else
        # jqが無い場合の簡易パース
        grep -o '"pattern":[[:space:]]*"[^"]*"' "$RULES_FILE" | sed 's/.*"pattern":[[:space:]]*"\([^"]*\)".*/\1/'
    fi
}

get_restricted_commands() {
    if command -v jq >/dev/null 2>&1; then
        jq -r '.restrictedCommands.commands | keys[]' "$RULES_FILE" 2>/dev/null || echo ""
    else
        # jqが無い場合の簡易パース
        grep -A 10 '"restrictedCommands"' "$RULES_FILE" | grep -o '"[^"]*"[[:space:]]*:' | sed 's/"//g' | sed 's/://'
    fi
}

get_command_info() {
    local command_key="$1"
    local info_type="$2"  # severity, reason, alternatives
    
    if command -v jq >/dev/null 2>&1; then
        case "$info_type" in
            "severity")
                jq -r --arg cmd "$command_key" '.dangerousCommands.patterns[] | select(.pattern == $cmd) | .severity' "$RULES_FILE" 2>/dev/null ||
                jq -r --arg cmd "$command_key" '.restrictedCommands.commands[$cmd].severity' "$RULES_FILE" 2>/dev/null ||
                echo "medium"
                ;;
            "reason")
                # Try dangerous patterns first
                local result=$(jq -r --arg cmd "$command_key" '.dangerousCommands.patterns[] | select(.pattern == $cmd) | .reason' "$RULES_FILE" 2>/dev/null)
                if [[ -n "$result" ]]; then
                    echo "$result"
                else
                    # Try restricted commands
                    result=$(jq -r --arg cmd "$command_key" '.restrictedCommands.commands[$cmd].reason' "$RULES_FILE" 2>/dev/null)
                    if [[ -n "$result" ]]; then
                        echo "$result"
                    else
                        echo "制限されたコマンド"
                    fi
                fi
                ;;
            "alternatives")
                # Try dangerous patterns first
                local result=$(jq -r --arg cmd "$command_key" '.dangerousCommands.patterns[] | select(.pattern == $cmd) | .alternatives[]' "$RULES_FILE" 2>/dev/null)
                if [[ -n "$result" ]]; then
                    echo "$result"
                else
                    # Try restricted commands
                    result=$(jq -r --arg cmd "$command_key" '.restrictedCommands.commands[$cmd].alternatives[]' "$RULES_FILE" 2>/dev/null)
                    if [[ -n "$result" ]]; then
                        echo "$result"
                    else
                        echo "より安全な方法を検討してください"
                    fi
                fi
                ;;
        esac
    else
        echo "jqが必要です"
    fi
}

# 危険なコマンドパターンのチェック
check_dangerous_command() {
    local command="$1"
    local found_patterns=()
    
    while IFS= read -r pattern; do
        if [[ -n "$pattern" && "$command" =~ $pattern ]]; then
            found_patterns+=("$pattern")
            log_message "DANGER: Dangerous pattern detected: $pattern"
        fi
    done < <(get_dangerous_patterns)
    
    if [[ ${#found_patterns[@]} -gt 0 ]]; then
        printf "%s\n" "${found_patterns[@]}"
        return 0
    fi
    
    return 1
}

# 制限されたコマンドのチェック
check_restricted_command() {
    local command="$1"
    local found_commands=()
    
    while IFS= read -r restricted; do
        if [[ -n "$restricted" && "$command" =~ $restricted ]]; then
            found_commands+=("$restricted")
            log_message "RESTRICTED: Restricted command detected: $restricted"
        fi
    done < <(get_restricted_commands)
    
    if [[ ${#found_commands[@]} -gt 0 ]]; then
        printf "%s\n" "${found_commands[@]}"
        return 0
    fi
    
    return 1
}

# 重要度に基づく処理
handle_severity() {
    local severity="$1"
    local command="$2"
    
    case "$severity" in
        "critical")
            cat << EOF >&2
🚨 CRITICAL: システムに重大な損害を与える可能性があります

実行予定のコマンド: $command

このコマンドは非常に危険です。実行を強く推奨しません。
EOF
            return 1  # 即座に停止
            ;;
        "high")
            cat << EOF >&2
⚠️  HIGH: 重要なセキュリティリスクがあります

実行予定のコマンド: $command
EOF
            return 0  # 警告表示だが選択可能
            ;;
        "medium")
            cat << EOF >&2
🚫 MEDIUM: 一般的な制限事項

実行予定のコマンド: $command
EOF
            return 0  # 確認後実行可能
            ;;
        "low")
            cat << EOF >&2
ℹ️  LOW: 軽微な注意事項

実行予定のコマンド: $command
EOF
            return 0  # 情報表示のみ
            ;;
        *)
            return 0
            ;;
    esac
}

# 代替案の表示
show_alternatives() {
    local command_key="$1"
    local alternatives
    
    echo "  💡 代替案:"
    while IFS= read -r alt; do
        if [[ -n "$alt" ]]; then
            echo "    - $alt"
        fi
    done < <(get_command_info "$command_key" "alternatives")
}

# メイン処理
main() {
    # 引数チェック
    if [[ $# -lt 1 ]]; then
        log_message "WARNING: No command provided, skipping validation"
        exit 0
    fi
    
    local command="$*"
    local dangerous_patterns
    local restricted_commands
    local is_critical=false
    
    log_message "Checking command: $command"
    
    # 危険なコマンドのチェック
    if dangerous_patterns=$(check_dangerous_command "$command"); then
        while IFS= read -r pattern; do
            if [[ -n "$pattern" ]]; then
                local severity=$(get_command_info "$pattern" "severity")
                local reason=$(get_command_info "$pattern" "reason")
                
                if ! handle_severity "$severity" "$command"; then
                    is_critical=true
                fi
                
                echo "理由: $reason" >&2
                show_alternatives "$pattern"
            fi
        done <<< "$dangerous_patterns"
    fi
    
    # 制限されたコマンドのチェック
    if restricted_commands=$(check_restricted_command "$command"); then
        while IFS= read -r cmd; do
            if [[ -n "$cmd" ]]; then
                local severity=$(get_command_info "$cmd" "severity")
                local reason=$(get_command_info "$cmd" "reason")
                
                if ! handle_severity "$severity" "$command"; then
                    is_critical=true
                fi
                
                echo "理由: $reason" >&2
                show_alternatives "$cmd"
            fi
        done <<< "$restricted_commands"
    fi
    
    # 問題が検出された場合の処理
    if [[ -n "$dangerous_patterns" ]] || [[ -n "$restricted_commands" ]]; then
        
        if [[ "$is_critical" == true ]]; then
            log_message "CRITICAL command blocked: $command"
            echo "" >&2
            echo "🛑 このコマンドは実行できません。" >&2
            exit 1
        fi
        
        cat << EOF >&2

実行を継続する場合は、以下のオプションを選択してください:
1. コマンドを変更する
2. --force フラグで強制実行する
3. 実行を中止する

EOF
        
        read -p "選択 (1/2/3): " -r choice
        case "$choice" in
            1)
                log_message "User chose to modify command"
                exit 1
                ;;
            2)
                log_message "User chose to force execution: $command"
                echo "⚠️  強制実行が選択されました。注意して実行してください。" >&2
                ;;
            3|"")
                log_message "User chose to abort execution"
                exit 1
                ;;
            *)
                log_message "Invalid choice, aborting execution"
                exit 1
                ;;
        esac
    fi
    
    log_message "Command approved: $command"
    exit 0
}

# エラーハンドリング
trap 'log_message "ERROR: Script failed at line $LINENO"' ERR

# メイン実行
main "$@"