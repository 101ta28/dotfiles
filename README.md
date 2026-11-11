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

After installation, configure your personal Git and Jujutsu settings:

```shell
# Run the user setup script
bash -c "$(curl -fsSL https://raw.githubusercontent.com/101ta28/dotfiles/main/setup-user.sh)"
```

Or if you have already cloned the repository:

```shell
./setup-user.sh
```

This will prompt you to enter:

- Your full name for Git and Jujutsu commits
- Your email address  
- Your GPG key ID (optional, for commit signing)

The same identity is saved to both tools. Providing a GPG key enables signing in Git and signing of your own commits in Jujutsu; leaving it empty disables automatic signing in both. If `jj` is unavailable, only Git is configured; rerun the script after installing Jujutsu.

## Update

Update the installed checkout with a fast-forward pull, then recreate links and install any newly required tools:

```shell
~/.dfiles/update.sh
```

The updater stops before changing files when `~/.dfiles` contains uncommitted changes or cannot be fast-forwarded. Commit or stash intentional local changes first. Use `~/.dfiles/update.sh --gpu` to retain the optional GPU/CUDA provisioning path.

For colocated Jujutsu/Git checkouts, the updater uses `jj git fetch` and the configured `trunk()` revision (usually `main@origin`). It requires an empty, conflict-free working-copy change with one parent, and creates a new empty change on the fetched target only if that parent can be fast-forwarded. If local commits are ahead of the target, it preserves them and reapplies configuration; diverged histories stop the update. Save working-copy changes with `jj commit` first. Git-only checkouts require a checked-out branch with an upstream configured.

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
- `.config/jj/config.toml.template` - Template copied to the Jujutsu user configuration on first installation
- `setup-user.sh` - Interactive script to configure personal settings
- `installer.sh` - Main installation script
- `update.sh` - Safe fast-forward update and configuration resync
- `uninstaller.sh` - Interactive removal with backups
- `init.vim` - Vim/Neovim configuration and dpp.vim startup
- `.config/nvim/dpp.ts` - dpp.vim plugin definitions
- `.config/herdr/config.toml` - Herdr configuration synced to `~/.config/herdr/config.toml`
- `.config/herdr-app/keys.json` - Windows Herdr app keybindings that prioritize Codex CLI; applied manually
- `.config/ghostty/config.ghostty` - Ghostty configuration synced to `~/.config/ghostty/config.ghostty`
- `.config/agents/skills.txt` - Unified manifest for external and local Agent Skills restored into `~/.agents/skills/`
- `.config/agents/skills/` - Local skills and overrides for external skills
- `AGENTS.md` - Contributor guidance for this repository
- `.config/.codex/` - Codex instructions and execution policy rules synced to `~/.codex/`; removed repository-managed paths are pruned via `obsolete-paths.txt`
- `.zshrc` - Zsh shell configuration with Prezto

## Architecture Overview

### Configuration Structure

- **Zsh**: Uses Prezto framework. Aliases and environment variables are defined in `.zshrc`
- **Git**: `.gitconfig` sets up GPG signing, aliases, and Git LFS
- **Jujutsu**: A personal TOML configuration holds identity and signing settings; `.zshrc` loads standard completions
- **Editor**: `init.vim` loads dpp.vim; `dpp.ts` defines plugins through Denops

### How installer.sh Works

1. Install Zsh and set it as the invoking user's default login shell
2. Clone the dotfiles repository
3. Install Prezto (Zsh framework)
4. Create symbolic links for configuration files
5. Bootstrap dpp.vim, Denops, and the required installer/Git extensions
6. Restore the declared Agent Skills into the user-level shared skills directory
7. Auto-install development tools (Deno, Node.js, pnpm, Rust, Bun, uv, etc.)

The default-shell change takes effect at the next login or in a new terminal. Run `exec zsh` to use it immediately in the current session.

### Development Environment

- **JavaScript/TypeScript**: NVM, Node.js, pnpm, Bun, Deno (required by dpp.vim)
- **Python**: uv (fast package manager)
- **Rust**: rustup, Cargo, cargo-binstall (when needed to install Jujutsu)
- **Version control**: Git, Jujutsu (`jj`)
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

`installer.sh` and `update.sh` copy `.config/.codex/rules/*.rules` to `~/.codex/rules/`. Files with the same name are updated; other rule files, including locally saved approvals in `default.rules`, are preserved. Restart Codex after syncing to load the rules.

The managed `jj.rules` follows the distinction in the [official Git approval example](https://learn.chatgpt.com/docs/enterprise/security-cookbook#require-approval-for-sensitive-commands): inspection commands such as `jj status`, `jj log`, and `jj diff` are allowed outside the sandbox; commits, history changes (including `restore`, `abandon`, and `rebase`), remote operations (`git fetch` / `git push`), configuration changes, and external command execution require approval. Bookmark and operation-log inspection is allowed, while changes require approval. Jujutsu inspection can still snapshot the working copy; use `--ignore-working-copy` when that must be avoided.

These are command-prefix rules, not an automatic risk classifier. They cover the common leading options listed in `jj.rules`; other option orders and custom aliases fall back to the normal sandbox and approval policy. Remove any separately saved blanket `prefix_rule(pattern=["jj"], decision="allow")` when migrating, since it would still allow unmatched forms. To sync only this rule, run `cp .config/.codex/rules/jj.rules ~/.codex/rules/jj.rules`, then restart Codex.

### pnpm

pnpm 11 is installed globally through npm after the NVM-managed Node.js LTS installation. On WSL, a pnpm executable inherited from the Windows PATH is ignored so that a native Linux installation is used. Verify it with:

```bash
pnpm --version
```

### Jujutsu

Following the [official installation and setup guide](https://docs.jj-vcs.dev/latest/install-and-setup/), the installer runs `cargo binstall --strategies crate-meta-data jj-cli --no-confirm` after Rust is available. It first installs a missing cargo-binstall with `cargo install cargo-binstall --locked`. An existing `jj` installation is preserved, including when running `update.sh`.

The installer copies `.config/jj/config.toml.template` to the path returned by `jj config path --user` (normally `~/.config/jj/config.toml`, respecting `XDG_CONFIG_HOME`). Existing configurations and configurations with multiple paths are preserved. Personal settings are edited with `jj config set --user` and are not linked back to the repository.

```bash
jj --version
./setup-user.sh
jj config edit --user
```

Zsh loads **standard** completions via `source <(jj util completion zsh)` after completion initialization. Open a new shell or run `source ~/.zshrc` to enable them.

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

Switch to the next tab with `Ctrl+Tab` and to the previous tab with `Ctrl+Shift+Tab`.

The Codex instructions in `.config/.codex/AGENTS.md` share the repository-targeting and delegation policy between the `herdr` TUI skill and the `herdr-app` desktop skill. Both verify the destination against live spaces and terminal directories, distinguish machines and worktrees, start subagents only when requested, and clean up only their own resources. Inherited IDs and UI focus may point to another repository.

The TUI uses a separate tab with `--no-focus`; if no workspace matches unambiguously, it creates one at the repository root and uses its initial tab. The app uses `hc` terminals without layout labels for background work, preserving the current view. Visible tabs/splits are created when requested; a missing repository space is then created as part of that request. App terminal addresses and pane IDs are distinct, and TUI command flags do not apply.

The local skills read the installed `herdr --skill`, `herdr-app --skill`, and `hc --skill` manuals for current interfaces. App-specific remote execution, terminal recovery, mods, layouts, and keys retain their own workflows; customization reads the generated guide and types in the app home. This adds skill support, not an app/core installation or a migration of live settings. The app and core must already be installed.

### Herdr app (Windows)

[`.config/herdr-app/keys.json`](.config/herdr-app/keys.json) stores the Windows desktop app's keybindings, with Codex CLI shortcuts taking priority. `F1`–`F12`, `Alt+Arrow`, and `Ctrl+Left/Right` go to the terminal program. `Ctrl+J` sends Windows key-down/key-up events to preserve Control+J through ConPTY; this binding is specific to Windows.

Install Herdr app and herdr-core first. From this repository's root, run the following in Windows PowerShell to back up the current key file and apply the configuration. `HERDR_APP_HOME` is respected when set.

```powershell
$ErrorActionPreference = 'Stop'
$herdrConfigDir = if ($env:HERDR_APP_HOME) {
    $env:HERDR_APP_HOME
} else {
    Join-Path $env:USERPROFILE '.config\herdr-app'
}
New-Item -ItemType Directory -Path $herdrConfigDir -Force | Out-Null
$herdrKeysPath = Join-Path $herdrConfigDir 'keys.json'
if (Test-Path -LiteralPath $herdrKeysPath) {
    $herdrBackupPath = "$herdrKeysPath.bak-$(Get-Date -Format yyyyMMdd-HHmmss-fff)"
    Copy-Item -LiteralPath $herdrKeysPath -Destination $herdrBackupPath
}
Copy-Item -LiteralPath '.config\herdr-app\keys.json' -Destination $herdrKeysPath
herdr-app status
```

Herdr reloads the file while running. Check `herdr-app status` for errors; an invalid file leaves the last working configuration active and writes `keys.error` in the app home. `installer.sh`, `update.sh`, and `uninstaller.sh` do not manage this Windows configuration.

| Herdr app action | Shortcut |
|---|---|
| Rename tab / space | `Ctrl+Shift+F2` / `Ctrl+Shift+F3` |
| Select tab 1–9 | `Ctrl+Shift+1`–`9` |
| Previous / next agent | `Alt+Shift+Up` / `Alt+Shift+Down` |
| Focus pane left / down / up / right | `Alt+H` / `J` / `K` / `L` |
| Show keybindings | `Ctrl+Shift+F1` |
| Zoom in / out / reset | `Alt+=` / `Alt+-` / `Alt+0` |

The configuration was prepared for Herdr app 0.1.15 and Codex CLI 0.167.1. JSON parsing, live reload, and Control+J reception in an isolated Windows console were checked; physical keypresses in Codex were not verified. After applying it, check that `Ctrl+J` inserts a newline in the composer and `F2` opens Codex warnings instead of Herdr's rename dialog. Customizing `keys.json` also stops Herdr from automatically replacing it with newer default keybindings; add new defaults manually when needed.

### Ghostty

The installer also links `.config/ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty` with the same existing-file policy. Ghostty itself is not installed. Non-color settings are based on GNOME Terminal profile `b1dcc9dd-5262-4d8d-a863-c897e6d979b9`: blinking block cursor, scrolling behavior, system bell, and closing after command exit. The font is customized to HackGen Console NF (13 pt), and the target initial display area is 134 columns × 34 rows to approximate the GNOME Terminal window size on this desktop. Since `window-height = 34` produced 31 visible rows, the configuration uses `window-width = 134` and `window-height = 37`. The user confirmed that this produces a visible area of 134 columns × 34 rows on this desktop; other desktops may need a different adjustment. Colors remain Ghostty defaults. Settings without an exact equivalent, such as the 10,000-line scrollback and always-visible scrollbar, retain Ghostty defaults. This is a snapshot; edit the repository file to change the settings. GTK window decorations can cause the actual grid size to differ from the requested initial size.

Global instructions hold shared communication and work boundaries. Detailed Japanese prose guidance lives in `japanese-tech-writing`; `cognitive-rhythm-writing` handles reading rhythm when needed. `frontend-design` covers visible UI work, and `grilling` covers requested interviews to challenge a plan. Keep skill descriptions specific to these tasks, and load additional guidance only when relevant.

`frontend-design` preserves the existing design system while guiding choices about color, spacing, typography, product visuals, and motion. It includes reviewing rendered views and fixing the most consequential issues within scope.

When used together, `hallmark` supplies visual direction and stylistic defaults, while `frontend-design` covers implementation, responsive behavior, accessibility, and functional verification. They share one workflow and prioritize user requirements and the existing design system.

The two writing skills clarify subjects and operations and improve sentence flow while preserving facts and conditions. They include editing examples and choose wording and structure for the context, without fixed sentence-length or list-ratio targets.

The `jj` skill covers Jujutsu working-copy changes, history rewrites, conflict recovery, bookmarks, and Git remotes. Its source is `.config/agents/skills/jj/`, synced to `~/.agents/skills/jj/` by the installer. It uses an existing `jj` installation.

### Agent Skills

All managed Agent Skills are declared in `.config/agents/skills.txt`. Both `installer.sh` and `update.sh` use the installer's `sync_agent_skills` function to restore them into `~/.agents/skills/`. The sync is additive: installed skills not listed in the manifest are preserved, and unlisted local directories are not copied.

Each entry contains a source and skill name, separated by whitespace. A repository source is installed globally with the Skills CLI; `local` copies `.config/agents/skills/<name>/`. For either source, files in that local directory take precedence over installed files. Empty lines and lines beginning with `#` are ignored. For example:

```text
nutlope/hallmark hallmark
local jj
```

The manifest includes four external skills (`hallmark`, `yomiyasu`, `herdr`, and `find-skills`) and six local skills (`cognitive-rhythm-writing`, `frontend-design`, `grilling`, `herdr-app`, `japanese-tech-writing`, and `jj`). To add a local skill, create `skills/<name>/SKILL.md` beside the manifest and add a `local <name>` entry. Duplicate names, invalid entries, and local directories missing `SKILL.md` stop skill syncing before any skill is installed or copied. Without `npx`, external installation is skipped with a warning while local files are still copied.

After installing `hallmark`, the installer copies `.config/agents/skills/hallmark/` over it. This directory stores the customized `SKILL.md`, `references/flow.md`, `references/gates.md`, and `references/redesign.md`, plus the reference validator, its tests, and the upstream license. Page composition details and the Picks example live in `references/flow.md` to keep the entrypoint within its size limit. Extension fields live under `metadata`; the validator accepts both this format and the upstream version field. Other scripts, themes, and resources still come from `nutlope/hallmark`. This order restores the local changes after each installation; check compatibility when updating upstream resources.

The `herdr` installation is also overlaid with `.config/agents/skills/herdr/SKILL.md`, preserving upstream resources while restoring the local TUI policy. The local `herdr-app` skill supplies desktop/core guidance and conditional references for orchestration and customization. Both remain available as separate entrypoints so their incompatible commands are not mixed.

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
- Codex instructions and execution policy rules are managed under `.config/.codex/`; run `update.sh` or rerun the installer to sync them and remove paths listed in `obsolete-paths.txt`
- All Agent Skills are managed under `.config/agents/`, declared in `skills.txt`, and restored additively; `~/.agents` itself is not tracked by Git
- Git LFS is enabled for handling large files

## Troubleshooting

### Local MCP connections fail behind a proxy

If Codex reports `codex_tui` startup failure and a Squid HTTP 503 page for `127.0.0.1`, the local request is being sent to the proxy. `.zshenv` merges existing `NO_PROXY` and `no_proxy` entries and adds `localhost`, `127.0.0.1`, and `::1` to both variables.

Exit Codex, run `source ~/.zshenv` in the launching Zsh, and start Codex again. Already-running processes do not pick up the updated environment.

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
- Terminal-browser cleanup: close tabs and panes created for the task before the final response unless explicitly asked to keep them open; preserve pre-existing browsers and tabs.
- Reusable workflows: declared in `.config/agents/skills.txt` and synced to `~/.agents/skills/`

### Agent Skills

- Declared in `.config/agents/skills.txt`: external sources use `npx skills add`; local skills and overrides are copied from `.config/agents/skills/`
- Shared skills directory: `~/.agents/skills/`

## License

These dotfiles are intended for personal use and can be freely used and modified.
