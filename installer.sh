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

# undo ディレクトリ
mkdir -p ~/.local/share/nvim/undo

# dpp/denops クローン（~/.cache/dpp に配置）
DPP_DIR="$HOME/.cache/dpp"
DPP_REPOS="$DPP_DIR/repos/github.com"

if [ ! -d "$DPP_REPOS/Shougo/dpp.vim" ]; then
  echo "Cloning dpp.vim..."
  mkdir -p "$DPP_REPOS/Shougo"
  git clone https://github.com/Shougo/dpp.vim "$DPP_REPOS/Shougo/dpp.vim"
fi

if [ ! -d "$DPP_REPOS/vim-denops/denops.vim" ]; then
  echo "Cloning denops.vim..."
  mkdir -p "$DPP_REPOS/vim-denops"
  git clone https://github.com/vim-denops/denops.vim "$DPP_REPOS/vim-denops/denops.vim"
fi

# dpp.ts（存在しない場合のみ生成）
DPP_TS="$HOME/.config/nvim/dpp.ts"
if [ ! -f "$DPP_TS" ]; then
  echo "Creating dpp.ts..."
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

# パッケージインストール
echo "Installing packages..."

sudo apt update
sudo apt install -y curl git build-essential unzip ca-certificates

# Neovim
if ! command -v nvim >/dev/null 2>&1; then
  sudo apt install -y neovim
fi

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

# 所有者の修正（念のため）
sudo chown -R "$USER":"$USER" "$DPP_DIR"

# 完了メッセージ
echo ""
echo "Setup complete!"
echo "Launch Neovim and run:"
echo "  :call dpp#make_state()"
echo "  :call dpp#check_plugins()"
echo ""
echo "Or just restart Neovim and it will run automatically on DenopsReady."
