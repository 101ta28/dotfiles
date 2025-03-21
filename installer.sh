#!/bin/sh

set -e

DFILE_PATH="$HOME/.dfiles"

# prezto のインストール
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "Cloning prezto..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# dotfiles のシンボリックリンク作成
ln -sf "$DFILE_PATH/.zshrc" ~/.zshrc          # zsh 設定
ln -sf "$DFILE_PATH/.zpreztorc" ~/.zpreztorc
ln -sf "$DFILE_PATH/.zlogin" ~/.zlogin
ln -sf "$DFILE_PATH/.zlogout" ~/.zlogout
ln -sf "$DFILE_PATH/.zprofile" ~/.zprofile

ln -sf "$DFILE_PATH/.gitconfig" ~/.gitconfig  # Git 設定
ln -sf "$DFILE_PATH/.profile" ~/.profile      # シェル用プロフィール

# vim 設定
mkdir -p ~/.vim/undo
ln -sf "$DFILE_PATH/.vimrc" ~/.vimrc

# dpp.vim インストール
DPP_DIR="$HOME/.vim/dpp"
DPP_REPOS="$DPP_DIR/repos/github.com"
DPP_INSTALLER="$DPP_REPOS/Shougo/dpp.vim"

if [ ! -d "$DPP_INSTALLER" ]; then
  echo "Installing dpp.vim..."
  mkdir -p "$DPP_REPOS/Shougo"
  git clone https://github.com/Shougo/dpp.vim "$DPP_INSTALLER"
fi

# 必要な依存もチェック
DENOPS_DIR="$DPP_REPOS/vim-denops/denops.vim"
if [ ! -d "$DENOPS_DIR" ]; then
  echo "Installing denops.vim..."
  mkdir -p "$DPP_REPOS/vim-denops"
  git clone https://github.com/vim-denops/denops.vim "$DENOPS_DIR"
fi

# dpp.ts の存在確認（なければテンプレート生成）
DPP_TS="$HOME/.vim/dpp.ts"
if [ ! -f "$DPP_TS" ]; then
  echo "Creating default dpp.ts..."
  cat > "$DPP_TS" <<EOF
export const plugins = [
  { repo: "Shougo/dpp.vim" },
  { repo: "vim-denops/denops.vim" },
  { repo: "itchyny/lightline.vim" },
  { repo: "cohama/lexima.vim" },
];
EOF
fi

# --- Package Installation Section ---

echo "Installing required packages..."

# Detect OS for package manager
install_with_package_manager() {
  PKG=$1
  if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y "$PKG"
  elif command -v brew >/dev/null 2>&1; then
    brew install "$PKG"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm "$PKG"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$PKG"
  fi
}

# nvm + node
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
fi

# rust
if ! command -v rustc >/dev/null 2>&1; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# gh (GitHub CLI)
if ! command -v gh >/dev/null 2>&1; then
  echo "Installing GitHub CLI..."
  install_with_package_manager gh
fi

# lsd
if ! command -v lsd >/dev/null 2>&1; then
  echo "Installing lsd..."
  if command -v cargo >/dev/null 2>&1; then
    cargo install lsd
  else
    install_with_package_manager lsd
  fi
fi

# bun
if [ ! -d "$HOME/.bun" ]; then
  echo "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# uv
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo "Package installation complete."

# 終了メッセージ
echo "Setup complete. Please launch Vim and run:"
echo "  :call dpp#make_state()"
echo "  :call dpp#check_plugins()"
