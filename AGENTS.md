# Repository Guidelines

## Project Structure & Module Organization

This repository manages a personal Ubuntu/WSL development environment. Root-level dotfiles such as `.zshrc`, `.zpreztorc`, and `.gitconfig.template` configure the shell and Git. `init.vim` and `.config/nvim/dein*.toml` define Vim/Neovim behavior and plugins. Lifecycle scripts are `installer.sh`, `update.sh`, and `uninstaller.sh`; `setup-user.sh` collects per-user Git settings. Codex configuration is under `.config/.codex/`. Keep English and Japanese documentation aligned in `README.md` and `README.ja.md` when behavior changes.

## Build, Test, and Development Commands

There is no compilation step or package manifest. Validate edited scripts without modifying the host environment:

```bash
bash -n installer.sh setup-user.sh update.sh uninstaller.sh
zsh -n .zshrc .zpreztorc .zprofile .zshenv
```

Run `./setup-user.sh` only when intentionally changing global Git configuration. The lifecycle scripts provide safe `--help` output; a full installation or update invokes `sudo`, package managers, network downloads, and symlink creation. Test `update.sh` with temporary local Git repositories so validation does not pull or provision the workstation.

## Coding Style & Naming Conventions

Follow the style of the file being edited. Shell functions and local variables use `snake_case`; constants use `UPPER_SNAKE_CASE`. Quote variable expansions, prefer `printf` for formatted output, and keep destructive operations behind explicit confirmation. Use two-space indentation for new Bash code while preserving a file's established style; Vim configuration uses four spaces (`shiftwidth=4`, `expandtab`). Add comments for intent or platform constraints, not for self-evident commands.

## Testing Guidelines

No automated test suite or coverage threshold is configured. At minimum, run syntax checks for every changed script and exercise affected option parsers with safe inputs. For installer changes, verify behavior in a fresh Ubuntu/WSL container or VM and report the tested platform. Never test uninstallation against a workstation containing irreplaceable configuration.

## Commit & Pull Request Guidelines

Recent commits use short, imperative subjects such as `Update AGENTS.md` and `Fix ExecPlan documentation path`. Keep each commit focused and explain user-visible behavior in the body when needed. Pull requests should summarize the affected configuration, list validation commands and platform details, and call out new packages, network access, `sudo` use, or migration steps. Link relevant issues; include screenshots only for visible editor or terminal UI changes.
