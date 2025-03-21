#!/bin/sh

set -e

# ~/.dfiles が存在しない場合は GitHub から clone
DFILE_PATH="$HOME/.dfiles"

if [ ! -d "$DFILE_PATH" ]; then
  echo "Cloning dotfiles into $DFILE_PATH..."
  git clone https://github.com/101ta28/dotfiles.git "$DFILE_PATH"
fi

# prezto のインストール
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "Cloning prezto..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# dotfiles のシンボリックリンク作成
ln -sf "$DFILE_PATH/.zshrc" ~/.zshrc
ln -sf "$DFILE_PATH/.zpreztorc" ~/.zpreztorc
ln -sf "$DFILE_PATH/.zlogin" ~/.zlogin
ln -sf "$DFILE_PATH/.zlogout" ~/.zlogout
ln -sf "$DFILE_PATH/.zprofile" ~/.zprofile
ln -sf "$DFILE_PATH/.gitconfig" ~/.gitconfig
ln -sf "$DFILE_PATH/.profile" ~/.profile

# init.vim 設定
mkdir -p ~/.config/nvim
ln -sf "$DFILE_PATH/init.vim" ~/.config/nvim/init.vim

# undo ディレクトリ作成（Neovim用）
mkdir -p ~/.local/share/nvim/undo

# dpp.vim インストール（Neovim用ディレクトリ）
DPP_DIR="$HOME/.config/nvim/dpp"
DPP_REPOS="$DPP_DIR/repos/github.com"
DPP_INSTALLER="$DPP_REPOS/Shougo/dpp.vim"

if [ ! -d "$DPP_INSTALLER" ]; then
  echo "Installing dpp.vim..."
  mkdir -p "$DPP_REPOS/Shougo"
  git clone https://github.com/Shougo/dpp.vim "$DPP_INSTALLER"
fi

# denops.vim のインストール
DENOPS_DIR="$DPP_REPOS/vim-denops/denops.vim"
if [ ! -d "$DENOPS_DIR" ]; then
  echo "Installing denops.vim..."
  mkdir -p "$DPP_REPOS/vim-denops"
  git clone https://github.com/vim-denops/denops.vim "$DENOPS_DIR"
fi

# dpp.ts の存在確認（なければテンプレート生成）
DPP_TS="$HOME/.config/nvim/dpp.ts"
if [ ! -f "$DPP_TS" ]; then
  echo "Creating default dpp.ts..."
  cat > "$DPP_TS" <<EOF
export const plugins = [
  { repo: "Shougo/dpp.vim" },
  { repo: "vim-denops/denops.vim" },
  { repo: "Shougo/dpp-ext-installer" },
  { repo: "Shougo/dpp-ext-lazy" },
  { repo: "itchyny/lightline.vim" },
  { repo: "cohama/lexima.vim" },
];
EOF
fi

# --- Package Installation Section ---

echo "Installing required packages..."

# 基本依存のインストール（Ubuntu前提）
sudo apt update
sudo apt install -y curl git build-essential unzip ca-certificates

# Neovim のインストール
if ! command -v nvim >/dev/null 2>&1; then
  echo "Installing Neovim..."
  sudo apt install -y neovim
fi

# nvm + node
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts

# rust
if ! command -v rustc >/dev/null 2>&1; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
export PATH="$HOME/.cargo/bin:$PATH"

# gh (GitHub CLI)
if ! command -v gh >/dev/null 2>&1; then
  echo "Installing GitHub CLI (latest method)..."
  (type -p wget >/dev/null || sudo apt install wget -y) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
fi

# lsd
if ! command -v lsd >/dev/null 2>&1; then
  echo "Installing lsd..."
  if command -v cargo >/dev/null 2>&1; then
    cargo install lsd
  else
    sudo apt install -y lsd
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
  curl https://astral.sh/uv/install.sh | sh
fi

# deno のインストール
if ! command -v deno >/dev/null 2>&1; then
  echo "Installing deno..."
  curl -fsSL https://deno.land/install.sh | sh
fi

# 完了メッセージ
echo ""
echo "Dotfiles and packages installed successfully."
echo "To finish Neovim setup, launch Neovim and run:"
echo "  :call dpp#make_state()"
echo "  :call dpp#check_plugins()"
echo ""
echo "You may now run 'exec zsh' or restart your terminal to start using zsh + prezto."
