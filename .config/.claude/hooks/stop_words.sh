#!/bin/bash
# =============================================================================
# Claude Code - NG Word Detection Hook
# =============================================================================
# このフックは、AIの応答に不適切な推測や代替案を示すワードが含まれている場合に
# 実行を停止します。

set -euo pipefail

# 設定ファイルのパス
RULES_FILE="$(dirname "$0")/rules.json"
LOG_FILE="$HOME/.claude/hooks.log"

# ログ関数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] STOP_WORDS: $1" >> "$LOG_FILE"
}

# JSONから配列を読み込む関数
get_ng_words() {
    if command -v jq >/dev/null 2>&1; then
        jq -r '.ngWords.words[]' "$RULES_FILE" 2>/dev/null || echo ""
    fi
}

# メイン処理
main() {
    # 引数チェック
    if [[ $# -lt 1 ]]; then
        log_message "WARNING: No input text provided, skipping check"
        exit 0
    fi
    
    local input_text="$1"
    local ng_words_found=()
    
    # NG Wordの検出
    while IFS= read -r ng_word; do
        if [[ -n "$ng_word" && "$input_text" =~ $ng_word ]]; then
            ng_words_found+=("$ng_word")
        fi
    done < <(get_ng_words)
    
    # NG Wordが見つかった場合
    if [[ ${#ng_words_found[@]} -gt 0 ]]; then
        log_message "NG words detected: ${ng_words_found[*]}"
        
        cat << EOF >&2
🚫 Claude Code Hook: NG Word Detection

以下のNG Wordが検出されました:
$(printf "  - %s\n" "${ng_words_found[@]}")

このメッセージは、AIが不確定な提案や余計な改善提案を行うことを防ぐためのものです。
より具体的で確実な指示をお願いします。

実行を継続する場合は、以下のオプションを選択してください:
1. 指示を具体的に変更する
2. --force フラグを使用する
3. この警告を無視する場合は Enter を押してください

EOF
        
        read -p "選択 (1/2/3): " -r choice
        case "$choice" in
            1)
                log_message "User chose to modify instruction"
                exit 1
                ;;
            2)
                log_message "User chose to force execution"
                ;;
            3|"")
                log_message "User chose to ignore warning"
                ;;
            *)
                log_message "Invalid choice, stopping execution"
                exit 1
                ;;
        esac
    fi
    
    log_message "No NG words detected or execution approved"
    exit 0
}

# エラーハンドリング
trap 'log_message "ERROR: Script failed at line $LINENO"' ERR

# メイン実行
main "$@"