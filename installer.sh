#!/bin/bash

set -e

# =============================================================================
# 設定
# =============================================================================
DFILE_PATH="$HOME/.dfiles"
DPP_DIR="$HOME/.cache/dpp"

# バージョン情報
NVM_VERSION="v0.40.2"

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# =============================================================================
# ユーティリティ関数
# =============================================================================
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

# Gitリポジトリをクローンする汎用関数
clone_repo() {
  local repo_url="$1"
  local target_dir="$2"
  local repo_name="$3"
  
  if [ ! -d "$target_dir" ]; then
    log_info "Installing $repo_name..."
    git clone "$repo_url" "$target_dir"
    log_success "$repo_name installed"
  else
    log_info "$repo_name already installed"
  fi
}

# シンボリックリンクを作成する関数
create_symlink() {
  local source="$1"
  local target="$2"
  
  # 既存のファイルがシンボリックリンクでない場合は警告
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    log_warn "File exists and is not a symlink: $target"
  else
    ln -sf "$source" "$target"
  fi
}

# コマンドの存在をチェックする関数
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# curlでインストールする汎用関数
install_via_curl() {
  local tool_name="$1"
  local install_url="$2"
  local check_command="$3"
  local install_args="${4:-}"
  
  if ! command_exists "$check_command"; then
    log_info "Installing $tool_name..."
    if [ -n "$install_args" ]; then
      curl -fsSL "$install_url" | sh -s -- $install_args
    else
      curl -fsSL "$install_url" | sh
    fi
    log_success "$tool_name installed"
  else
    log_info "$tool_name already installed"
  fi
}

# =============================================================================
# オプション解析
# =============================================================================
INSTALL_GPU=false

# 引数解析
while [[ $# -gt 0 ]]; do
  case $1 in
    --gpu)
      INSTALL_GPU=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --gpu     Install GPU/CUDA development tools"
      echo "  --help    Show this help message"
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# =============================================================================
# メイン処理
# =============================================================================

# dotfiles リポジトリがなければ clone
clone_repo "https://github.com/101ta28/dotfiles.git" "$DFILE_PATH" "dotfiles"

# prezto インストール
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  log_info "Installing prezto..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  log_success "prezto installed"
else
  log_info "prezto already installed"
fi

# シンボリックリンク作成
log_info "Creating symbolic links..."

# Zsh関連の設定ファイル
ZSH_CONFIGS=".zshrc .zpreztorc .zlogin .zlogout .zprofile .zshenv"
for config in $ZSH_CONFIGS; do
  if [ -f "$DFILE_PATH/$config" ]; then
    create_symlink "$DFILE_PATH/$config" "$HOME/$config"
  fi
done

# その他の設定ファイル
create_symlink "$DFILE_PATH/.profile" "$HOME/.profile"

# .gitconfig を .gitconfig.template からコピー
if [ -f "$DFILE_PATH/.gitconfig.template" ] && [ ! -f "$HOME/.gitconfig" ]; then
  log_info "Creating .gitconfig from template..."
  cp "$DFILE_PATH/.gitconfig.template" "$HOME/.gitconfig"
  log_success ".gitconfig created from template"
else
  log_info ".gitconfig already exists or template not found"
fi

# Neovim 設定
mkdir -p ~/.config/nvim
create_symlink "$DFILE_PATH/init.vim" "$HOME/.config/nvim/init.vim"
create_symlink "$DFILE_PATH/.config/nvim/dpp.ts" "$HOME/.config/nvim/dpp.ts"


# Vim 設定
create_symlink "$DFILE_PATH/init.vim" "$HOME/.vimrc"

# undo ディレクトリ
mkdir -p ~/.local/share/nvim/undo

log_success "Symbolic links created"

# =============================================================================
# dpp.vim とその依存関係をインストール
# =============================================================================
log_info "Setting up dpp.vim and dependencies..."

mkdir -p "$DPP_DIR/repos/github.com/Shougo"
mkdir -p "$DPP_DIR/repos/github.com/vim-denops"

# dpp.vim関連のリポジトリ
DPP_REPOS=(
  "Shougo/dpp.vim|$DPP_DIR/repos/github.com/Shougo/dpp.vim|dpp.vim"
  "vim-denops/denops.vim|$DPP_DIR/repos/github.com/vim-denops/denops.vim|denops.vim"
  "Shougo/dpp-ext-installer|$DPP_DIR/repos/github.com/Shougo/dpp-ext-installer|dpp-ext-installer"
)

for repo_info in "${DPP_REPOS[@]}"; do
  repo_url=$(echo "$repo_info" | cut -d'|' -f1)
  target_dir=$(echo "$repo_info" | cut -d'|' -f2)
  repo_name=$(echo "$repo_info" | cut -d'|' -f3)
  clone_repo "https://github.com/$repo_url" "$target_dir" "$repo_name"
done

# =============================================================================
# パッケージインストール (Ubuntu専用)
# =============================================================================
log_info "Installing system packages..."
sudo apt update
sudo apt install -y curl git build-essential unzip ca-certificates jq ripgrep fzf neovim

# =============================================================================
# 開発ツールのインストール
# =============================================================================

# nvm + node
if [ ! -d "$HOME/.nvm" ]; then
  log_info "Installing NVM..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  log_success "NVM installed"
fi

# NVMを読み込んでNode.jsをインストール
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  log_info "Installing Node.js (LTS)..."
  nvm install --lts
  log_success "Node.js installed"
fi

# Rust
install_via_curl "Rust" "https://sh.rustup.rs" "rustc" "-y"
export PATH="$HOME/.cargo/bin:$PATH"

# GitHub CLI
if ! command_exists "gh"; then
  log_info "Installing GitHub CLI..."
  (command_exists wget || sudo apt install wget -y)
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y
  log_success "GitHub CLI installed"
else
  log_info "GitHub CLI already installed"
fi

# lsd
if ! command_exists "lsd"; then
  if command_exists "cargo"; then
    log_info "Installing lsd via cargo..."
    cargo install lsd
    log_success "lsd installed"
  else
    log_info "Installing lsd via apt..."
    sudo apt install -y lsd
    log_success "lsd installed"
  fi
else
  log_info "lsd already installed"
fi

# bun
if [ ! -d "$HOME/.bun" ]; then
  install_via_curl "Bun" "https://bun.sh/install" "dummy"  # bunはディレクトリで判定
fi

# Claude Code CLI
if command_exists "bun"; then
  # Check if Claude Code CLI is actually installed
  if ! command_exists "claude"; then
    log_info "Installing Claude Code CLI..."
    bun install -g @anthropic-ai/claude-code
    log_success "Claude Code CLI installed"
    
    # Run migrate-installer for new installations
    log_info "Running Claude Code migrate installer..."
    bunx claude migrate-installer
    log_success "Claude Code migrate installer completed"
  else
    log_info "Claude Code CLI already installed"
    
    # Check if migration is needed (if local claude binary doesn't exist)
    if [ ! -f "$HOME/.claude/local/claude" ]; then
      log_info "Claude Code migration needed - running migrate-installer..."
      bunx claude migrate-installer
      log_success "Claude Code migrate installer completed"
    fi
  fi
  
  # Claude Code設定のコピー
  if [ -d "$DFILE_PATH/.config/.claude" ]; then
    log_info "Copying Claude Code configuration..."
    mkdir -p "$HOME/.claude"
    # 設定ファイルをコピー（既存のファイルは上書きしない）
    cp -rn "$DFILE_PATH/.config/.claude/"* "$HOME/.claude/" 2>/dev/null || true
    log_success "Claude Code configuration copied"
  fi
else
  log_warn "Bun not found, skipping Claude Code CLI installation"
fi

# uv
install_via_curl "uv" "https://astral.sh/uv/install.sh" "uv"

# deno (dpp.vim requires Deno 1.45+)
install_via_curl "Deno (required for dpp.vim)" "https://deno.land/install.sh" "deno"

# =============================================================================
# GPU/CUDA 開発ツールのインストール (オプション)
# =============================================================================
if [ "$INSTALL_GPU" = true ]; then
  log_info "Installing GPU/CUDA development tools..."
  
  # NVIDIA Container Toolkit (Docker with GPU support)
  if ! command_exists "nvidia-container-runtime"; then
    log_info "Installing NVIDIA Container Toolkit..."
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    log_success "NVIDIA Container Toolkit installed"
  else
    log_info "NVIDIA Container Toolkit already installed"
  fi
  
  # CUDA Toolkit (development version)
  if ! command_exists "nvcc"; then
    log_info "Installing CUDA Toolkit..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt update
    sudo apt install -y cuda-toolkit-12-6
    rm cuda-keyring_1.1-1_all.deb
    log_success "CUDA Toolkit installed"
  else
    log_info "CUDA Toolkit already installed"
  fi
  
  log_success "GPU/CUDA development tools installation complete!"
  echo ""
  log_info "Note: You may need to restart your system for GPU drivers to work properly."
  log_info "To verify CUDA installation, run: nvidia-smi"
fi

# =============================================================================
# 完了メッセージ
# =============================================================================
echo ""
log_success "Setup complete!"
echo ""
echo "Launch Vim or Neovim. dpp.vim will set up automatically."
echo "Note: Deno is required for dpp.vim to work properly."
echo ""
echo "To configure your personal Git settings, run:"
echo "  bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/setup-user.sh)\""
echo "  or: ./setup-user.sh"
echo ""
log_warn "IMPORTANT: Please restart your shell or run 'source ~/.zshrc' to apply changes."
echo "  exec zsh  # or restart your terminal"