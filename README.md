# Dotfiles

Personal dotfiles for development environment setup.

[日本語のREADMEはこちら](./README.ja.md)

## Installation

### Basic Installation (CPU only)

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)"
```

### GPU/CUDA Development Installation

For GPU development with CUDA support:

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)" -s --gpu
```

This will install:

- NVIDIA Container Toolkit (Docker with GPU support)
- CUDA Toolkit 12.6

## Post-Installation Setup

After installation, you need to configure your personal Git settings:

```shell
# Run the user setup script
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/setup-user.sh)"
```

Or if you have already cloned the repository:

```shell
./setup-user.sh
```

This will prompt you to enter:

- Your full name for Git commits
- Your email address  
- Your GPG key ID (optional, for commit signing)

## Security Notes

⚠️ **Important**: Before using these dotfiles:

1. **Review the configuration files** to ensure they meet your security requirements
2. **Customize personal settings** in `.gitconfig` using the provided template
3. **Set up GPG signing** if you want signed commits (recommended)
4. **Review installed tools** and remove any you don't need

## Files Overview

- `.gitconfig.template` - Template for Git configuration with placeholders
- `setup-user.sh` - Interactive script to configure personal settings
- `installer.sh` - Main installation script
- `init.vim` - Vim/Neovim configuration (using dpp.vim for plugin management)
- `.config/nvim/dpp.ts` - TypeScript configuration file for dpp.vim
- `.zshrc` - Zsh shell configuration with Prezto
- `CLAUDE.md` - AI instructions for this repository

## Architecture Overview

### Configuration Structure

- **Zsh**: Uses Prezto framework. Aliases and environment variables are defined in `.zshrc`
- **Git**: `.gitconfig` sets up GPG signing, aliases, and Git LFS
- **Editor**: `init.vim` manages plugins via dpp.vim (TypeScript config: `.config/nvim/dpp.ts`)

### How installer.sh Works

1. Clone dotfiles repository
2. Install Prezto (Zsh framework)
3. Create symbolic links for configuration files
4. Install dpp.vim, denops.vim, and dpp-ext-installer
5. Auto-install development tools (Node.js, Rust, Bun, uv, Deno, etc.)

### Development Environment

- **JavaScript/TypeScript**: NVM, Bun, Deno
- **Python**: uv (fast package manager)
- **Rust**: rustup, Cargo
- **Others**: Go, CUDA (GPU computing), GitHub CLI
- **GPU/CUDA** (optional): NVIDIA Container Toolkit, CUDA Toolkit 12.6

## Common Commands

### Initial Setup

```bash
# Install dotfiles (run on new environment)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/installer.sh)"
```

### Vim/Neovim

```bash
# Edit init.vim with Neovim
nvim ~/.config/nvim/init.vim

# Edit dpp.vim TypeScript config
nvim ~/.config/nvim/dpp.ts

# Plugins are installed automatically
# To manually install plugins (run inside Vim/Neovim)
:call dpp#install()
```

### Updating Dotfiles

```bash
# Commit changes (with GPG signature if configured)
git add .
git cm -m "message"  # cm is alias for commit

# Push to remote
git push origin main
```

## GPG Setup (Optional)

To enable GPG signing for commits:

```shell
# Generate a new GPG key
gpg --full-generate-key

# List GPG keys to get the key ID
gpg --list-secret-keys --keyid-format LONG

# Configure Git to use your key
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgSign true
```

## Important Notes

- Commits are automatically GPG signed (if configured)
- `ls` command is aliased to `lsd` (feature-rich ls written in Rust)
- Japanese input is configured with fcitx
- dpp.vim requires Deno 1.45+ (auto-installed by installer.sh)
- Git LFS is enabled for handling large files

## Troubleshooting

### dpp.vim not working

1. Check if Deno is installed: `deno --version`
2. Ensure Deno version is 1.45 or higher
3. Restart Vim/Neovim

### GPG signing errors

1. Verify GPG key is properly configured
2. Temporarily disable GPG signing: `git config --global commit.gpgSign false`
3. Re-run setup-user.sh to review settings

### GPU/CUDA issues

1. Check NVIDIA driver installation: `nvidia-smi`
2. Verify CUDA Toolkit installation: `nvcc --version`
3. System restart may be required
4. For Ubuntu versions other than 22.04, CUDA installation script may need adjustments

## License

These dotfiles are intended for personal use and can be freely used and modified.
