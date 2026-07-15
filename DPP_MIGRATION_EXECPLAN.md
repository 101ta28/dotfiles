# Migrate Vim plugin management from dein to dpp

This ExecPlan is a living document. Keep `Progress`, `Surprises & Discoveries`,
`Decision Log`, and `Outcomes & Retrospective` current as work proceeds.
Maintain this document in accordance with `~/.codex/PLANS.md`.

## Purpose / Big Picture

Vim and Neovim load the existing lightline and lexima plugins through dpp.vim instead of dein.vim. A fresh dotfiles installation bootstraps dpp, Denops, the Git protocol, the installer extension, and a compatible Deno runtime. Existing installations receive the new configuration through `update.sh`; the obsolete dein configuration is no longer linked or documented. Users can observe successful setup through dpp's state-generation message and can run `:DppInstall` or `:DppUpdate` explicitly.

## Progress

- [x] (2026-07-15 03:58Z) Inspected repository instructions, current plugin-manager configuration, lifecycle scripts, and documentation.
- [x] (2026-07-15 03:58Z) Reviewed the official dpp.vim, dpp-ext-installer, dpp-ext-toml, and dpp-protocol-git documentation.
- [x] (2026-07-15 04:03Z) Added the dpp TypeScript configuration and replaced dein initialization in `init.vim`.
- [x] (2026-07-15 04:05Z) Updated installation, migration, and uninstallation behavior for dpp and Deno.
- [x] (2026-07-15 04:07Z) Aligned English/Japanese documentation and contributor guidance.
- [x] (2026-07-15 04:11Z) Passed shell/editor syntax, Deno type checking, safe migration, and dpp state-path fixtures.

## Surprises & Discoveries

- Observation: dpp does not bundle installation or Git support and requires Denops.
  Evidence: Official help requires Deno 2.3.0+, denops.vim 8.0+, dpp-ext-installer for remote installation, and dpp-protocol-git for Git repositories.
- Observation: The current installer removes Deno during uninstallation but never installs it.
  Evidence: `uninstaller.sh` contains a Deno removal branch, while `installer.sh` has no Deno setup.
- Observation: The existing plugin set has only two runtime plugins and no active lazy definitions.
  Evidence: `.config/nvim/dein.toml` lists lightline and lexima; `.config/nvim/dein_lazy.toml` contains only a comment.
- Observation: dpp's current `Plugin` type requires an explicit `name`, and Denops' generated `fn.expand()` wrapper returns `unknown`.
  Evidence: The first `deno check .config/nvim/dpp.ts` reported six TS2741 errors and one TS2322 error.

## Decision Log

- Decision: Define plugins directly in `.config/nvim/dpp.ts` instead of retaining TOML.
  Rationale: Two non-lazy plugins do not justify the extra dpp-ext-toml and dpp-ext-lazy bootstrap dependencies.
  Date/Author: 2026-07-15, Codex.
- Decision: Bootstrap dpp.vim, denops.vim, dpp-ext-installer, and dpp-protocol-git in `installer.sh`.
  Rationale: These are the minimum components required to generate state and install Git-hosted plugins.
  Date/Author: 2026-07-15, Codex.
- Decision: Preserve explicit install/update commands and trigger installation after state generation.
  Rationale: This retains the previous first-run convenience while providing recoverable manual operations.
  Date/Author: 2026-07-15, Codex.

## Outcomes & Retrospective

Vim/Neovim plugin management now uses dpp exclusively at runtime. The TypeScript configuration passed `deno check` against the real JSR packages after explicit plugin names and a string cast for `fn.expand()` were added. Isolated Vim fixtures proved both a loaded-state startup and the first-run `DenopsReady` → state generation → installer action sequence. An isolated installer fixture proved correct bootstrap paths, managed legacy-link removal, unrelated-link preservation, and `dpp.ts` linking. Full startup with a real Neovim 0.11.3+ process and real plugin clones was not run on this workstation because no compatible Neovim is installed; the installer reports this requirement rather than replacing the user's editor package source.

## Context and Orientation

`init.vim` loads dpp from `~/.cache/dpp` and generates state from `.config/nvim/dpp.ts` through Denops when that state is missing or stale. `installer.sh` links the TypeScript file, clones the four bootstrap repositories, and installs a compatible Deno. `uninstaller.sh` removes the link and optionally backs up/removes the dpp cache. Both READMEs describe dpp commands and version requirements. dpp itself has no built-in Git or installer behavior, so bootstrap repositories must exist before the first state is generated.

## Plan of Work

Create `.config/nvim/dpp.ts` with the four bootstrap plugins plus lightline and lexima, using the Git protocol and no lazy extension. Replace the dein block in `init.vim` with guarded dpp runtime setup, Denops-ready state generation, first-run install, and `DppInstall`/`DppUpdate` commands. Modify `installer.sh` to link `dpp.ts`, remove only old symlinks managed by this repository, install Deno 2.3 or newer, and clone the four bootstrap repositories under `~/.cache/dpp/repos/github.com`. Modify `uninstaller.sh` to remove the dpp link and back up/remove the dpp cache. Update `README.md`, `README.ja.md`, and `AGENTS.md` to describe the new paths, requirements, commands, and troubleshooting.

## Concrete Steps

Work from `/home/tatsuya/dotfiles`:

    bash -n installer.sh setup-user.sh update.sh uninstaller.sh
    zsh -n .zshrc .zpreztorc .zprofile .zshenv
    vim -Nu init.vim -n -es -c 'qa!'
    rg -n 'dein#|Shougo/dein.vim|DEIN_DIR' --hidden -g '!.git/**' .
    git diff --check

Use a temporary HOME and command stubs to exercise installer symlink migration and bootstrap destinations without running APT or downloading packages on the workstation.

## Validation and Acceptance

All shell and Zsh syntax checks must pass. Vim must parse `init.vim` without a dpp checkout and exit cleanly after displaying only an actionable warning. No runtime integration may invoke dein; its name may remain only in safe migration cleanup and migration documentation. `.config/nvim/dpp.ts` must list dpp, Denops, the installer and Git protocol, lightline, and lexima. Installer fixtures must prove that `dpp.ts` is linked, old repository-owned links are removed, unrelated links are preserved, and all bootstrap clones target `~/.cache/dpp`. Both READMEs must document `:DppInstall`, `:DppUpdate`, Deno, and the supported editor requirement.

## Idempotence and Recovery

Repository cloning and symlink creation remain safe to repeat. Existing regular files are never overwritten. Old dein links are removed only when their targets match this dotfiles checkout; unrelated user links are preserved. A failed dpp state build can be retried by restarting the editor or calling `dpp#make_state()` after resolving the reported Deno or bootstrap problem. The old dein cache is not deleted during installation; users can remove it after confirming dpp works.

## Artifacts and Notes

Validation produced these concise results:

    bash and zsh syntax: passed
    Vim config parse without dpp: passed
    dpp.ts Deno type check: passed
    dpp.ts Bun parse/bundle: passed
    loaded-state Vim fixture: passed
    first-state/install Vim fixture: passed
    installer link/bootstrap fixture: passed
    unrelated legacy-link preservation: passed
    git diff --check: passed

Fixtures are under `/tmp/dpp-installer-fixture-20260715`, `/tmp/dpp-vim-fixture-20260715`, and `/tmp/dpp-vim-bootstrap-fixture-20260715`. Deno was installed only under `/tmp/dpp-deno-20260715` for type checking; no host editor plugins or package-manager state changed.

## Interfaces and Dependencies

dpp requires Vim 9.1.1646+ or Neovim 0.11.3+, Deno 2.3.0+, and denops.vim 8.0+. The bootstrap repositories are `Shougo/dpp.vim`, `vim-denops/denops.vim`, `Shougo/dpp-ext-installer`, and `Shougo/dpp-protocol-git`. The TypeScript configuration extends `BaseConfig`, returns a `ConfigReturn` containing `plugins` and `stateLines`, and enables the `git` protocol. Runtime installation and updates use `dpp#async_ext_action('installer', 'install'|'update')`.

Revision note (2026-07-15): Marked migration complete, corrected the current-state context, and recorded type-check and isolated runtime evidence plus the compatible-Neovim limitation.
