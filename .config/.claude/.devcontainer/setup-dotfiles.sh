#!/bin/bash
# =============================================================================
# Claude Code - Dotfiles Setup Script for Container
# =============================================================================
# このスクリプトは、開発コンテナ内でdotfiles環境を初期化します。

set -euo pipefail

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

main() {
    log_info "Setting up dotfiles environment in container..."
    
    # 環境変数の設定
    export PATH="/home/node/.cargo/bin:/home/node/.local/bin:/home/node/.bun/bin:/home/node/.deno/bin:$PATH"
    
    # Preztoの設定（存在しない場合のみ）
    if [[ ! -d "/home/node/.zprezto" ]]; then
        log_info "Installing Prezto..."
        git clone --recursive https://github.com/sorin-ionescu/prezto.git /home/node/.zprezto
    fi
    
    # Powerlevel10k設定のコピー
    if [[ -f ".devcontainer/p10k.zsh" ]]; then
        log_info "Setting up Powerlevel10k configuration..."
        cp .devcontainer/p10k.zsh /home/node/.p10k.zsh
        
        # .zshrcにPowerlevel10k設定を追加（まだ追加されていない場合）
        if [[ -f "/home/node/.zshrc" ]] && ! grep -q "p10k.zsh" /home/node/.zshrc; then
            echo "" >> /home/node/.zshrc
            echo "# Powerlevel10k configuration" >> /home/node/.zshrc
            echo "source /home/node/.powerlevel10k/powerlevel10k.zsh-theme" >> /home/node/.zshrc
            echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> /home/node/.zshrc
        fi
    fi
    
    # Neovim設定ディレクトリの作成
    mkdir -p /home/node/.config/nvim
    
    # dpp.vim関連のディレクトリ作成（存在しない場合のみ）
    if [[ ! -d "/home/node/.cache/dpp/repos/github.com/Shougo/dpp.vim" ]]; then
        log_info "Setting up dpp.vim..."
        mkdir -p /home/node/.cache/dpp/repos/github.com/{Shougo,denops}
        
        # dpp.vim関連のリポジトリをクローン
        git clone https://github.com/Shougo/dpp.vim /home/node/.cache/dpp/repos/github.com/Shougo/dpp.vim
        git clone https://github.com/denops/denops.vim /home/node/.cache/dpp/repos/github.com/denops/denops.vim
        git clone https://github.com/Shougo/dpp-ext-installer /home/node/.cache/dpp/repos/github.com/Shougo/dpp-ext-installer
    fi
    
    # Neovim設定ファイルのリンク（dotfilesがマウントされている場合）
    if [[ -f "/home/node/.vimrc" && ! -L "/home/node/.config/nvim/init.vim" ]]; then
        ln -sf /home/node/.vimrc /home/node/.config/nvim/init.vim
    fi
    
    # dpp.ts設定ファイルのリンク
    if [[ -f "/home/node/.config/.claude/../nvim/dpp.ts" && ! -L "/home/node/.config/nvim/dpp.ts" ]]; then
        ln -sf /home/node/.config/.claude/../nvim/dpp.ts /home/node/.config/nvim/dpp.ts
    fi
    
    # undoディレクトリの作成
    mkdir -p /home/node/.local/share/nvim/undo
    
    # 権限設定
    chown -R node:node /home/node/.cache /home/node/.config /home/node/.local /home/node/.zprezto 2>/dev/null || true
    
    # ツールのバージョン確認
    log_info "Installed tools:"
    command -v node && node --version
    command -v bun && bun --version
    command -v deno && deno --version
    command -v uv && uv --version
    command -v cargo && cargo --version
    command -v lsd && lsd --version
    
    log_success "Dotfiles setup completed!"
    log_info "You can now use:"
    log_info "  - bun instead of npm"
    log_info "  - uv for Python package management"
    log_info "  - lsd for enhanced ls"
    log_info "  - Claude Code hooks are active"
}

# メイン実行
main "$@"