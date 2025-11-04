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
- `init.vim` - Vim/Neovim configuration (using dein.vim for plugin management)
- `.config/nvim/dein.toml` - dein.vim plugin definition (eager load)
- `.config/nvim/dein_lazy.toml` - dein.vim plugin definition (lazy load)
- `AGENTS.md` - Shared agent instructions synced to `~/.codex/AGENTS.md`
- `.zshrc` - Zsh shell configuration with Prezto
- `.config/.claude/hooks/` - Claude Code custom hooks for security and workflow control
- `CLAUDE.md` - AI instructions for this repository

## Architecture Overview

### Configuration Structure

- **Zsh**: Uses Prezto framework. Aliases and environment variables are defined in `.zshrc`
- **Git**: `.gitconfig` sets up GPG signing, aliases, and Git LFS
- **Editor**: `init.vim` manages plugins via dein.vim (`dein.toml` / `dein_lazy.toml`)

### How installer.sh Works

1. Clone dotfiles repository
2. Install Prezto (Zsh framework)
3. Create symbolic links for configuration files
4. Install dein.vim plugin manager
5. Auto-install development tools (Node.js, Rust, Bun, uv, etc.)

### Development Environment

- **JavaScript/TypeScript**: NVM, Bun
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

# Edit dein.vim plugin definition
nvim ~/.config/nvim/dein.toml

# Plugins are installed automatically
# To manually install plugins (run inside Vim/Neovim)
:call dein#install()
```

### Codex CLI

```bash
# Check the installed version
codex --version

# Edit synced agent instructions
nvim ~/.codex/AGENTS.md
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
- dein.vim installs plugins defined in `dein.toml`
- Codex CLI uses `AGENTS.md`; rerun the installer or copy the file manually to refresh instructions
- Git LFS is enabled for handling large files
- Claude Code hooks provide security controls and workflow automation

## Troubleshooting

### dein.vim not working

1. Update plugin metadata: `:call dein#update()`
2. Ensure `~/.cache/dein` is writable
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

### Claude Code hooks not working

1. Check hook file permissions: `ls -la ~/.claude/hooks/`
2. Ensure hooks have execute permissions: `chmod +x ~/.claude/hooks/*.sh`
3. Check hook logs: `cat ~/.claude/hooks.log`
4. Verify rules.json syntax: validate JSON structure

## AI Tool Integration

This repository includes CLI tooling for Claude Code and Codex to streamline AI-assisted workflows.

### Claude Code

Custom hooks for Claude Code provide:

### Security Features
- **Command filtering**: Prevents execution of dangerous commands (rm -rf, sudo operations, etc.)
- **Word filtering**: Detects uncertain or speculative language in AI responses
- **Preferred tooling**: Enforces use of modern tools (bun over npm, uv over pip)

### Hook Files
- `.config/.claude/hooks/rules.json` - Configuration for security rules and preferred tools
- `.config/.claude/hooks/stop_words.sh` - Filters AI responses for problematic language
- `.config/.claude/hooks/pre_commands.sh` - Validates commands before execution  
- `.config/.claude/hooks/post_commands.sh` - Analyzes command results and logs statistics

### Setup Claude Code Hooks

```bash
# Make hooks executable
chmod +x ~/.claude/hooks/*.sh

# Test hook functionality
~/.claude/hooks/stop_words.sh "This might be a suggestion"
~/.claude/hooks/pre_commands.sh "npm install"
```

See `.config/.claude/hooks/README.md` for detailed configuration and customization options.

### Codex CLI
- Installed via `bun install -g @openai/codex`
- Configuration directory: `~/.codex/`
- Agent instructions: copy or edit `~/.codex/AGENTS.md` (managed from this repository's `AGENTS.md`)

## License

These dotfiles are intended for personal use and can be freely used and modified.
