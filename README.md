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

## Update

Update the installed checkout with a fast-forward pull, then recreate links and install any newly required tools:

```shell
~/.dfiles/update.sh
```

The updater stops before changing files when `~/.dfiles` contains uncommitted changes or cannot be fast-forwarded. Commit or stash intentional local changes first. Use `~/.dfiles/update.sh --gpu` to retain the optional GPU/CUDA provisioning path.

## Uninstall

Run the interactive uninstaller from the installed checkout:

```shell
~/.dfiles/uninstaller.sh
```

The script backs up configuration before optional removal steps and asks separately before removing tools, the repository, or shell settings.

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
- `update.sh` - Safe fast-forward update and configuration resync
- `uninstaller.sh` - Interactive removal with backups
- `init.vim` - Vim/Neovim configuration and dpp.vim startup
- `.config/nvim/dpp.ts` - dpp.vim plugin definitions
- `.config/herdr/config.toml` - Herdr configuration synced to `~/.config/herdr/config.toml`
- `.config/agents/skills.txt` - Agent Skills restored into `~/.agents/skills/`
- `AGENTS.md` - Contributor guidance for this repository
- `.config/.codex/` - Codex instructions and local skills synced to `~/.codex/` and `~/.agents/skills/`; removed repository-managed paths are pruned via `obsolete-paths.txt`
- `.zshrc` - Zsh shell configuration with Prezto

## Architecture Overview

### Configuration Structure

- **Zsh**: Uses Prezto framework. Aliases and environment variables are defined in `.zshrc`
- **Git**: `.gitconfig` sets up GPG signing, aliases, and Git LFS
- **Editor**: `init.vim` loads dpp.vim; `dpp.ts` defines plugins through Denops

### How installer.sh Works

1. Clone dotfiles repository
2. Install Prezto (Zsh framework)
3. Create symbolic links for configuration files
4. Bootstrap dpp.vim, Denops, and the required installer/Git extensions
5. Restore the declared Agent Skills into the user-level shared skills directory
6. Auto-install development tools (Deno, Node.js, Rust, Bun, uv, etc.)

### Development Environment

- **JavaScript/TypeScript**: NVM, Bun, Deno (required by dpp.vim)
- **Python**: uv (fast package manager)
- **Rust**: rustup, Cargo
- **Others**: Go, Herdr, CUDA (GPU computing), GitHub CLI
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

# Edit dpp.vim plugin definitions
nvim ~/.config/nvim/dpp.ts

# Run inside Vim/Neovim when manual installation or updates are needed
:DppInstall
:DppUpdate
```

dpp.vim requires Deno 2.3.0+, denops.vim 8.0+, and a supported editor (Neovim 0.11.3+ or Vim 9.1.1646+). The installer installs Deno and warns when the APT-provided Neovim is too old.

When upgrading an existing installation, `update.sh` removes only the obsolete symlinks created by this repository. After confirming dpp works, the unused `~/.cache/dein` directory can be removed manually.

### Codex CLI

```bash
# Check the installed version
codex --version

# Edit synced agent instructions
nvim ~/.codex/AGENTS.md
```

### Herdr

```bash
# Start the terminal multiplexer
herdr

# Update a direct installation
herdr update

# Reload the synced configuration
herdr server reload-config
```

The installer installs Herdr to `~/.local/bin/herdr` using its official installer and links `.config/herdr/config.toml` to `~/.config/herdr/config.toml`. An existing non-symlink file is preserved unless its contents already match the repository copy.

### Agent Skills

The installer reads `.config/agents/skills.txt` and installs each entry globally with the Skills CLI. This restores the declared skills into `~/.agents/skills/` on a new machine and whenever `update.sh` reapplies the configuration. The sync is additive: skills not listed in the manifest are preserved.

To add a synchronized skill, add its source repository and skill name to the manifest, separated by whitespace, one entry per line. Empty lines and lines beginning with `#` are ignored.

### Updating Dotfiles

```bash
~/.dfiles/update.sh
```

### Uninstalling Dotfiles

```bash
~/.dfiles/uninstaller.sh
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
- dpp.vim generates state and installs plugins defined in `dpp.ts` on first editor startup
- Codex instructions and local skills are managed under `.config/.codex/`; rerun the installer to sync them and remove paths listed in `obsolete-paths.txt`
- Agent Skills listed in `.config/agents/skills.txt` are restored additively; `~/.agents` itself is not tracked by Git
- Git LFS is enabled for handling large files

## Troubleshooting

### dpp.vim not working

1. Check versions with `deno --version` and `nvim --version` (or `vim --version`)
2. Ensure `~/.cache/dpp` is writable and the bootstrap repositories exist below `~/.cache/dpp/repos/github.com`
3. Restart the editor to regenerate state, then run `:DppInstall`; use `:DppUpdate` for later updates

### GPG signing errors

1. Verify GPG key is properly configured
2. Temporarily disable GPG signing: `git config --global commit.gpgSign false`
3. Re-run setup-user.sh to review settings

### GPU/CUDA issues

1. Check NVIDIA driver installation: `nvidia-smi`
2. Verify CUDA Toolkit installation: `nvcc --version`
3. System restart may be required
4. For Ubuntu versions other than 22.04, CUDA installation script may need adjustments

## AI Tool Integration

### Codex CLI
- Installed via `bun install -g @openai/codex`
- Configuration directory: `~/.codex/`
- Agent instructions: synced from `.config/.codex/AGENTS.md` to `~/.codex/AGENTS.md`
- Local reusable workflows: synced from `.config/.codex/skills/` to `~/.agents/skills/`

### Agent Skills

- Installed globally with `npx skills add` from `.config/agents/skills.txt`
- Shared skills directory: `~/.agents/skills/`

## License

These dotfiles are intended for personal use and can be freely used and modified.
