#!/bin/sh
# =============================================================================
# Dotfiles Uninstaller Script
# =============================================================================
# このスクリプトは、dotfiles環境を安全にアンインストールします。

set -e

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

# 確認関数
confirm_action() {
    local action="$1"
    printf "${YELLOW}❓ %s を実行しますか? (y/N): ${NC}" "$action"
    read -r response
    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ファイルまたはディレクトリが存在し、シンボリックリンクの場合に削除
remove_symlink() {
    local target="$1"
    if [[ -L "$target" ]]; then
        log_info "Removing symlink: $target"
        rm -f "$target"
        log_success "Removed: $target"
    elif [[ -e "$target" ]]; then
        log_warn "File exists but is not a symlink: $target"
        if confirm_action "Remove file $target"; then
            rm -rf "$target"
            log_success "Removed: $target"
        else
            log_info "Skipped: $target"
        fi
    fi
}

# バックアップディレクトリの作成
create_backup() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# メイン処理
main() {
    log_info "Starting dotfiles uninstallation..."
    
    # 警告メッセージ
    cat << EOF
${RED}⚠️  WARNING ⚠️${NC}

This script will remove the following:
- All dotfiles symlinks
- Installed tools (optional)
- Configuration directories
- Cache and temporary files

${YELLOW}Make sure you have backed up any important data!${NC}

EOF
    
    if ! confirm_action "Continue with uninstallation"; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
    
    # バックアップディレクトリの作成
    BACKUP_DIR=$(create_backup)
    log_info "Backup directory created: $BACKUP_DIR"
    
    # =================================================================
    # 1. シンボリックリンクの削除
    # =================================================================
    log_info "Removing dotfiles symlinks..."
    
    # Zsh関連
    remove_symlink "$HOME/.zshrc"
    remove_symlink "$HOME/.zpreztorc"
    remove_symlink "$HOME/.zlogin"
    remove_symlink "$HOME/.zlogout"
    remove_symlink "$HOME/.zprofile"
    remove_symlink "$HOME/.zshenv"
    
    # Git設定
    remove_symlink "$HOME/.gitconfig"
    remove_symlink "$HOME/.profile"
    
    # エディタ設定
    remove_symlink "$HOME/.vimrc"
    remove_symlink "$HOME/.config/nvim/init.vim"
    remove_symlink "$HOME/.config/nvim/dpp.ts"
    
    # Claude Code設定
    remove_symlink "$HOME/.config/.claude"
    
    log_success "Symlinks removal completed"
    
    # =================================================================
    # 2. 設定ディレクトリとキャッシュの削除
    # =================================================================
    if confirm_action "Remove configuration directories and cache"; then
        log_info "Removing configuration directories..."
        
        # Prezto
        if [[ -d "$HOME/.zprezto" ]]; then
            log_info "Backing up and removing Prezto..."
            cp -r "$HOME/.zprezto" "$BACKUP_DIR/zprezto" 2>/dev/null || true
            rm -rf "$HOME/.zprezto"
            log_success "Removed: $HOME/.zprezto"
        fi
        
        # Powerlevel10k
        if [[ -d "$HOME/.powerlevel10k" ]]; then
            log_info "Removing Powerlevel10k..."
            rm -rf "$HOME/.powerlevel10k"
            log_success "Removed: $HOME/.powerlevel10k"
        fi
        
        # dpp.vim cache
        if [[ -d "$HOME/.cache/dpp" ]]; then
            log_info "Backing up and removing dpp.vim cache..."
            cp -r "$HOME/.cache/dpp" "$BACKUP_DIR/dpp-cache" 2>/dev/null || true
            rm -rf "$HOME/.cache/dpp"
            log_success "Removed: $HOME/.cache/dpp"
        fi
        
        # Neovim undo directory
        if [[ -d "$HOME/.local/share/nvim/undo" ]]; then
            log_info "Removing Neovim undo directory..."
            rm -rf "$HOME/.local/share/nvim/undo"
            log_success "Removed: $HOME/.local/share/nvim/undo"
        fi
        
        # Claude logs
        if [[ -f "$HOME/.claude/hooks.log" ]]; then
            log_info "Backing up Claude logs..."
            cp "$HOME/.claude/hooks.log" "$BACKUP_DIR/" 2>/dev/null || true
            rm -f "$HOME/.claude/hooks.log"
        fi
        
        if [[ -f "$HOME/.claude/command_stats.log" ]]; then
            cp "$HOME/.claude/command_stats.log" "$BACKUP_DIR/" 2>/dev/null || true
            rm -f "$HOME/.claude/command_stats.log"
        fi
    fi
    
    # =================================================================
    # 3. インストールされたツールの削除（オプション）
    # =================================================================
    if confirm_action "Remove installed modern tools (bun, uv, deno, lsd, etc.)"; then
        log_info "Removing installed tools..."
        
        # Bun
        if [[ -d "$HOME/.bun" ]]; then
            log_info "Removing Bun..."
            rm -rf "$HOME/.bun"
            log_success "Removed: Bun"
        fi
        
        # Deno
        if [[ -d "$HOME/.deno" ]]; then
            log_info "Removing Deno..."
            rm -rf "$HOME/.deno"
            log_success "Removed: Deno"
        fi
        
        # uv
        if [[ -f "$HOME/.local/bin/uv" ]]; then
            log_info "Removing uv..."
            rm -f "$HOME/.local/bin/uv"
            rm -f "$HOME/.local/bin/uvx"
            log_success "Removed: uv"
        fi
        
        # Cargo/Rust ツール（慎重に削除）
        if confirm_action "Remove Rust/Cargo and installed packages (lsd, etc.)"; then
            if [[ -d "$HOME/.cargo" ]]; then
                log_info "Backing up and removing Cargo..."
                cp -r "$HOME/.cargo" "$BACKUP_DIR/cargo" 2>/dev/null || true
                rm -rf "$HOME/.cargo"
                log_success "Removed: Cargo"
            fi
            
            if [[ -d "$HOME/.rustup" ]]; then
                log_info "Removing Rustup..."
                rm -rf "$HOME/.rustup"
                log_success "Removed: Rustup"
            fi
        fi
        
        # NVM（オプション）
        if confirm_action "Remove NVM"; then
            if [[ -d "$HOME/.nvm" ]]; then
                log_info "Backing up and removing NVM..."
                cp -r "$HOME/.nvm" "$BACKUP_DIR/nvm" 2>/dev/null || true
                rm -rf "$HOME/.nvm"
                log_success "Removed: NVM"
            fi
        fi
    fi
    
    # =================================================================
    # 4. dotfilesリポジトリの削除
    # =================================================================
    if confirm_action "Remove dotfiles repository ($HOME/.dfiles)"; then
        if [[ -d "$HOME/.dfiles" ]]; then
            log_info "Backing up and removing dotfiles repository..."
            cp -r "$HOME/.dfiles" "$BACKUP_DIR/dfiles" 2>/dev/null || true
            rm -rf "$HOME/.dfiles"
            log_success "Removed: $HOME/.dfiles"
        fi
    fi
    
    # =================================================================
    # 5. シェル設定のリセット
    # =================================================================
    if confirm_action "Reset shell to system default"; then
        log_info "Resetting shell configuration..."
        
        # デフォルトシェルをbashに変更（システム依存）
        if command -v chsh >/dev/null 2>&1; then
            if confirm_action "Change default shell back to bash"; then
                chsh -s /bin/bash
                log_success "Default shell changed to bash"
            fi
        fi
        
        # .bashrcにメッセージを追加（存在しない場合）
        if [[ ! -f "$HOME/.bashrc" ]]; then
            cat > "$HOME/.bashrc" << 'EOF'
# Default .bashrc
# Dotfiles have been uninstalled

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

EOF
            log_success "Created basic .bashrc"
        fi
    fi
    
    # =================================================================
    # 完了メッセージ
    # =================================================================
    log_success "Dotfiles uninstallation completed!"
    
    cat << EOF

${GREEN}✅ Uninstallation Summary:${NC}
- Symlinks removed
- Configuration directories cleaned
- Tools removed (if selected)
- Backup created at: ${BACKUP_DIR}

${YELLOW}Next Steps:${NC}
1. Restart your terminal or run: source ~/.bashrc
2. Check the backup directory for any files you want to restore
3. Remove the backup directory when no longer needed:
   rm -rf "${BACKUP_DIR}"

${BLUE}Note:${NC}
- Your original system configurations should now be active
- Some tools may still be available if installed system-wide
- You can reinstall dotfiles anytime using the installer script

EOF
}

# エラーハンドリング
trap 'log_error "Uninstallation failed at line $LINENO"' ERR

# メイン実行
main "$@"