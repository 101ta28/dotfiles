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

The updater stops before changing files when `~/.dfiles` contains uncommitted changes or cannot be fast-forwarded. Commit or stash intentional local changes first.

Normal installation and updates do not install GPU/CUDA tools or enable CUDA shell paths. Use `~/.dfiles/update.sh --gpu` to install the optional tools and link `~/.zshrc.gpu`. Only this optional file adds CUDA paths, using `/usr/local/cuda` by default (override with `CUDA_PATH` before loading `.zshrc`). Later normal updates preserve this opt-in configuration and installed GPU/CUDA tools.

The old unconditional CUDA 12.9 paths have been removed. To keep enabling CUDA paths through these dotfiles, run with `--gpu` once. Start a fresh login session to avoid inheriting paths from the old shell.

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
- `.config/herdr-app/keys.json` - Shared Linux/Windows Herdr app keybindings that prioritize Codex CLI
- `.config/herdr-app/apply-windows.ps1` - Apply the shared keybindings on Windows with a backup
- `.config/ghostty/config.ghostty` - Ghostty configuration synced to `~/.config/ghostty/config.ghostty`
- `.config/agents/skills.txt` - Unified manifest for external and local Agent Skills restored into `~/.agents/skills/`
- `.config/agents/skills/` - Local skills and overrides for external skills
- `AGENTS.md` - Contributor guidance for this repository
- `.config/.codex/` - Codex instructions and execution policy rules synced to `~/.codex/`; removed repository-managed paths are pruned via `obsolete-paths.txt`
- `.zshrc` - Zsh shell configuration with Prezto
- `.zshrc.gpu` - Optional CUDA paths, linked only when installing or updating with `--gpu`

## Architecture Overview

### Configuration Structure

- **Zsh**: Uses Prezto framework. Aliases and environment variables are defined in `.zshrc`
- **Git**: `.gitconfig` sets up GPG signing, aliases, and Git LFS
- **Jujutsu**: A personal TOML configuration holds identity and signing settings; `.zshrc` loads standard and dynamic completions
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
- **Browser tools**: terminal-browser, agent-browser (including its browser and Linux libraries)
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

`agent-browser.rules` lets Codex browse without approval through `agent-browser-inspect`. For example, `agent-browser-inspect open https://example.com` opens a page and `agent-browser-inspect snapshot -i` lists its interactive elements. The helper also supports reading page text, checking element state, waiting for a page to load, and taking a screenshot at the default temporary path. Use `--session NAME` to select a session or `--json` for structured output.

Codex requests approval for direct `agent-browser` commands, including clicks, form input, uploads, JavaScript execution, and access to saved credentials. The helper checks every argument because the CLI also accepts launch options such as `--config` after a read command. The installer places the helper in `~/.local/bin` and syncs its rule and usage instructions.

The managed `herdr-app.rules` allows all subcommands of `hc`, `herdr-app`, and `herdr-app.exe`, including terminal execution and app changes. To sync only this rule, run `cp .config/.codex/rules/herdr-app.rules ~/.codex/rules/herdr-app.rules`, then restart Codex.

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

Zsh loads standard completions via `source <(jj util completion zsh)`, followed by dynamic completions via `source <(COMPLETE=zsh jj)`, after completion initialization. Open a new shell or run `source ~/.zshrc` to enable them.

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

Short commands and brief setup run directly. For work needing a separate terminal, the TUI uses a tab with `--no-focus`; if no workspace matches unambiguously, it creates one at the repository root and uses its initial tab.

The app uses a split for related output that should be viewed side by side, such as a dev server or live log, and a named tab for independently monitored work or work needing a full terminal, such as a large browser download, build, or test suite. Routine task-local tabs/splits and a missing repository space need no further confirmation. App 0.1.16 supports `--focus false` on `space.new` and `tab.new` to preserve the current selection. Programs run in the chosen app terminal; unlabeled `hc run --bg` is reserved for explicitly requested hidden execution or core-only environments. An exit notification does not establish that a pane exists. App terminal addresses and pane IDs are distinct, and TUI command flags do not apply.

The local skills read the installed `herdr --skill`, `herdr-app --skill`, and `hc --skill` manuals for current interfaces. App-specific remote execution, terminal recovery, mods, layouts, and keys retain their own workflows; customization reads the generated guide and types in the app home. This adds skill support, not an app/core installation or a migration of live settings. The app and core must already be installed.

### Herdr app (Linux / Windows)

The shared [`.config/herdr-app/keys.json`](.config/herdr-app/keys.json) passes `F1`–`F12`, `Alt+Arrow`, and `Ctrl+Left/Right` to the terminal program. Apply it on the OS running the Herdr app window, including Windows when the terminal runs in WSL.

#### Linux

From the repository root, copy the common configuration. GNU `cp --backup=numbered` keeps an existing file as `keys.json.~1~`, `keys.json.~2~`, and so on. `HERDR_APP_HOME` overrides the destination when set.

```bash
herdr_config_dir="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
mkdir -p "$herdr_config_dir"
cp --backup=numbered .config/herdr-app/keys.json "$herdr_config_dir/keys.json"
herdr-app status
```

#### Windows

From the repository root, run the following in PowerShell. The helper copies the shared `keys.json` to `$env:USERPROFILE\.config\herdr-app` or `HERDR_APP_HOME` when set. It backs up an existing file before replacing it and skips an identical configuration.

```powershell
& .\.config\herdr-app\apply-windows.ps1
herdr-app status
```

Use `-ConfigDir <directory>` to choose another app configuration directory. After updating the shared keybindings, rerun the command for your platform. Herdr app settings are managed separately from `installer.sh`, `update.sh`, and `uninstaller.sh`.

Herdr reloads `keys.json` while running. Check `herdr-app status` for errors; an invalid file leaves the last working configuration active and writes `keys.error` in the app home.

| Herdr app action | Shortcut |
|---|---|
| Rename tab / space | `Ctrl+Shift+F2` / `Ctrl+Shift+F3` |
| Select tab 1–9 | `Ctrl+Shift+1`–`9` |
| Previous / next agent | `Alt+Shift+Up` / `Alt+Shift+Down` |
| Focus pane left / down / up / right | `Alt+H` / `Alt+J` / `Alt+K` / `Alt+L` |
| Show keybindings | `Ctrl+Shift+F1` |
| Zoom in / out / reset | `Alt+=` / `Alt+-` / `Alt+0` |

Herdr preserves a customized `keys.json` across upgrades. Add new default shortcuts manually when needed.

### Ghostty

The installer also links `.config/ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty` with the same existing-file policy. Ghostty itself is not installed. Non-color settings are based on GNOME Terminal profile `b1dcc9dd-5262-4d8d-a863-c897e6d979b9`: blinking block cursor, scrolling behavior, system bell, and closing after command exit. The font is customized to HackGen Console NF (13 pt), and the target initial display area is 134 columns × 34 rows to approximate the GNOME Terminal window size on this desktop. Since `window-height = 34` produced 31 visible rows, the configuration uses `window-width = 134` and `window-height = 37`. The user confirmed that this produces a visible area of 134 columns × 34 rows on this desktop; other desktops may need a different adjustment. Colors remain Ghostty defaults. Settings without an exact equivalent, such as the 10,000-line scrollback and always-visible scrollbar, retain Ghostty defaults. This is a snapshot; edit the repository file to change the settings. GTK window decorations can cause the actual grid size to differ from the requested initial size.

Global instructions hold shared communication and work boundaries. Detailed Japanese prose guidance lives in `japanese-tech-writing`; `cognitive-rhythm-writing` handles reading rhythm when needed. `frontend-design` covers visible UI work, and `grilling` covers requested interviews to challenge a plan. Keep skill descriptions specific to these tasks, and load additional guidance only when relevant.

`frontend-design` preserves the existing design system while guiding choices about color, spacing, typography, product visuals, and motion. It includes reviewing rendered views and fixing the most consequential issues within scope.

When used together, `hallmark` supplies visual direction and `frontend-design` covers implementation, accessibility, and checks on the rendered interface. Both follow the brief and the existing design system. Hallmark uses Inspo when it was selected to build the page and uses Together AI for design comps only when generation is authorized for the task and the key is available.

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
- Agent Skills declared in `.config/agents/skills.txt` are managed under `.config/agents/` and restored additively; `~/.agents` itself is not tracked by Git. terminal-browser also provides its own bundled skill through its setup process
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
- Browser selection: use `terminal-browser` to review pages with the user or let them interact with the page; use `agent-browser` for work the agent can complete independently. Default to `agent-browser` when no shared view is needed, honor an explicit user choice, and switch to `terminal-browser` if user participation becomes necessary.
- Terminal-browser cleanup: close tabs and panes created for the task before the final response unless explicitly asked to keep them open; preserve pre-existing browsers and tabs.
- Reusable workflows: declared in `.config/agents/skills.txt` and synced to `~/.agents/skills/`

### Agent Skills

- Declared in `.config/agents/skills.txt`: external sources use `npx skills add`; local skills and overrides are copied from `.config/agents/skills/`
- Shared skills directory: `~/.agents/skills/`
- The `agent-browser` skill is restored from `vercel-labs/agent-browser`. The bundled `terminal-browser` skill is installed by its official setup process, outside this manifest.

### Browser tools

Normal installation and `update.sh` install both tools when missing:

- [agent-browser](https://github.com/vercel-labs/agent-browser): `npm install --global agent-browser`, followed by `agent-browser install --with-deps` to download its browser and install Linux libraries. The latter also runs when the CLI is already installed, so an interrupted browser download can be retried.
- [terminal-browser](https://terminal-browser.com/): the official `https://terminal-browser.sh/install` script installs the CLI and bundled browser. Its setup may ask to install the agent skill and configure terminal integration; accept the skill prompt to enable it. Rerun `terminal-browser setup` if needed. The CLI directory (`${XDG_BIN_HOME:-$HOME/.local/bin}`) is added to PATH for the installer process.

These steps download browser binaries and may use `sudo` for Linux libraries and terminal-browser's sandbox setup. Existing CLIs are preserved. To use terminal-browser's visible interface, use a terminal that supports the kitty graphics protocol. See the Codex instructions above for choosing between the two tools.

## License

These dotfiles are intended for personal use and can be freely used and modified.
