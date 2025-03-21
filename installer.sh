#!/bin/sh

set -e

DFILE_PATH="$HOME/.dfiles"

# dotfiles リポジトリがなければ clone
if [ ! -d "$DFILE_PATH" ]; then
  echo "Cloning dotfiles into $DFILE_PATH..."
  git clone https://github.com/101ta28/dotfiles.git "$DFILE_PATH"
fi

# prezto インストール
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "Installing prezto..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# シンボリックリンク作成
ln -sf "$DFILE_PATH/.zshrc" ~/.zshrc
ln -sf "$DFILE_PATH/.zpreztorc" ~/.zpreztorc
ln -sf "$DFILE_PATH/.zlogin" ~/.zlogin
ln -sf "$DFILE_PATH/.zlogout" ~/.zlogout
ln -sf "$DFILE_PATH/.zprofile" ~/.zprofile
ln -sf "$DFILE_PATH/.gitconfig" ~/.gitconfig
ln -sf "$DFILE_PATH/.profile" ~/.profile

# Neovim 設定リンク
mkdir -p ~/.config/nvim
ln -sf "$DFILE_PATH/init.vim" ~/.config/nvim/init.vim

# Vim 設定リンク
ln -sf "$DFILE_PATH/init.vim" ~/.vimrc

# undo ディレクトリ
mkdir -p ~/.local/share/nvim/undo

# dein.vim をインストール
DEIN_DIR="$HOME/.cache/dein"
if [ ! -d "$DEIN_DIR/repos/github.com/Shougo/dein.vim" ]; then
  echo "Installing dein.vim..."
  curl -sfL https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | sh -s "$DEIN_DIR"
fi

# 不要になった dpp 関連を削除
rm -rf ~/.cache/dpp
rm -f ~/.config/nvim/dpp.ts

# パッケージインストール
echo "Installing packages..."

sudo apt update
sudo apt install -y curl git build-essential unzip ca-certificates

# nvm + node
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts

# Rust
if ! command -v rustc >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
export PATH="$HOME/.cargo/bin:$PATH"

# GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
  (type -p wget >/dev/null || sudo apt install wget -y)
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y
fi

# lsd
if ! command -v lsd >/dev/null 2>&1; then
  if command -v cargo >/dev/null 2>&1; then
    cargo install lsd
  else
    sudo apt install -y lsd
  fi
fi

# bun
if [ ! -d "$HOME/.bun" ]; then
  curl -fsSL https://bun.sh/install | bash
fi

# uv
if ! command -v uv >/dev/null 2>&1; then
  curl https://astral.sh/uv/install.sh | sh
fi

# deno
if ! command -v deno >/dev/null 2>&1; then
  curl -fsSL https://deno.land/install.sh | sh
fi

# 完了メッセージ
echo ""
echo "Setup complete!"
echo "Launch Vim or Neovim and run:"
echo "  :call dein#install()"
echo ""
