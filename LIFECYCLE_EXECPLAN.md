# Add safe install, update, and uninstall operations

This ExecPlan is a living document. Keep `Progress`, `Surprises & Discoveries`,
`Decision Log`, and `Outcomes & Retrospective` current as work proceeds.
Maintain this document in accordance with `~/.codex/PLANS.md`.

## Purpose / Big Picture

Users can install the dotfiles on a new Ubuntu/WSL environment, update an existing checkout without discarding local configuration changes, and uninstall it through three documented scripts. Retired AI-tool files, installation logic, shell helpers, and documentation are absent. The result is observable through each script's help output, syntax validation, and an isolated update test using temporary Git repositories.

## Progress

- [x] (2026-07-15 02:04Z) Inspected repository instructions, lifecycle scripts, documentation, and current working-tree changes.
- [x] (2026-07-15 02:06Z) Implemented a configuration-preserving update command and made the installer reusable through `--dotfiles-dir`.
- [x] (2026-07-15 02:06Z) Removed retired AI-tool runtime and documentation references while preserving the user's existing deletions.
- [x] (2026-07-15 02:07Z) Corrected the uninstaller's shell declaration, added safe help output, and aligned contributor guidance.
- [x] (2026-07-15 02:08Z) Passed syntax, content, help-output, whitespace, and isolated updater validation.

## Surprises & Discoveries

- Observation: `uninstaller.sh` declares `/bin/sh` but uses Bash-only `[[ ... ]]`, `local`, and `LINENO` behavior.
  Evidence: `uninstaller.sh:1`, `uninstaller.sh:35`, and `uninstaller.sh:51`.
- Observation: Retired AI-tool configuration files are already deleted in the working tree and must not be restored.
  Evidence: `git status --short` lists the configuration directory as deleted.
- Observation: `uninstaller.sh` did not have its executable bit set, so the documented direct invocation failed.
  Evidence: `./uninstaller.sh --help` returned `permission denied` during the first validation pass.

## Decision Log

- Decision: Add `update.sh` rather than overloading installation with implicit Git pulls.
  Rationale: Explicit lifecycle commands are easier to understand, document, and run safely.
  Date/Author: 2026-07-15, Codex.
- Decision: Refuse updates on a dirty dotfiles checkout and use only fast-forward pulls.
  Rationale: This guarantees that updating never overwrites, stashes, rebases, or merges local configuration changes.
  Date/Author: 2026-07-15, Codex.
- Decision: Let `installer.sh` accept `--dotfiles-dir` for updater reuse.
  Rationale: The updater must recreate links from the checkout that was actually updated, not always from `~/.dfiles`.
  Date/Author: 2026-07-15, Codex.

## Outcomes & Retrospective

The repository now exposes three documented operations: `installer.sh` for initial provisioning, `update.sh` for a guarded fast-forward plus resynchronization, and `uninstaller.sh` for interactive removal with backups. The updater demonstrably preserves a dirty checkout by refusing to pull, while a clean checkout advances and delegates to its own installer. Retired integration references are absent from current content, and the user's pre-existing configuration deletions remain intact. Full provisioning and destructive uninstallation were intentionally not run on the workstation; they still require a disposable Ubuntu/WSL environment for end-to-end verification.

## Context and Orientation

`installer.sh` provisions packages and links repository files into `$HOME`; it currently assumes the checkout is `$HOME/.dfiles`. `setup-user.sh` writes personal Git identity. `uninstaller.sh` interactively removes links, optional tools, and the checkout. `README.md` and `README.ja.md` document operation. `.zshrc`, the installer, the uninstaller, and both READMEs still contain references to a retired AI tool even though its configuration has been deleted. `AGENTS.md` is the contributor guide created in the current working tree.

## Plan of Work

First, extend `installer.sh` with a validated `--dotfiles-dir` option and remove retired CLI/configuration setup while retaining Codex setup. Add `update.sh`, which resolves its own checkout, rejects local changes, verifies an upstream branch, performs `git pull --ff-only`, and reruns the installer against that checkout. Next, remove retired helpers and cleanup steps from `.zshrc` and `uninstaller.sh`, change the uninstaller to Bash, and revise both READMEs and `AGENTS.md` around the three lifecycle commands. Finally, validate syntax and use temporary local Git repositories plus a stub installer to prove dirty-tree refusal and successful fast-forward update without requiring network or host provisioning.

## Concrete Steps

Work from `/home/tatsuya/dotfiles`:

    bash -n installer.sh setup-user.sh update.sh uninstaller.sh
    zsh -n .zshrc .zpreztorc .zprofile .zshenv
    git diff --check

Create temporary repositories under `/tmp` for updater tests. Expected evidence is a nonzero exit for a dirty checkout and a successful fast-forward followed by invocation of the checkout's installer for a clean checkout.

## Validation and Acceptance

`./installer.sh --help`, `./update.sh --help`, and `./uninstaller.sh --help` must be safe and explain their purpose. All lifecycle scripts must pass `bash -n`; Zsh configuration must pass `zsh -n`. No tracked or newly generated content may reference the retired integration. An isolated dirty repository must remain byte-for-byte unchanged after an update attempt. An isolated clean repository must advance to its upstream revision and call the stub installer with its own path. English and Japanese READMEs must both present installation, updating, and uninstallation.

## Idempotence and Recovery

Syntax and content checks are repeatable. Installation is designed to skip existing tools and avoid replacing regular configuration files. Update refuses dirty repositories and fast-forwards only, so a failure leaves local commits and edits intact; rerun after resolving the reported Git state. Uninstallation remains interactive and creates a backup before removals. Temporary test repositories can be removed after validation without affecting the workspace.

## Artifacts and Notes

Validation on 2026-07-15 produced these concise results:

    bash syntax: passed
    zsh syntax: passed
    lifecycle --help commands: passed
    git diff --check: passed
    retired integration references: 0
    dirty update fixture: refused with HEAD and local file preserved
    clean update fixture: fast-forwarded and invoked installer

The isolated Git fixture was created under `/tmp/dotfiles-update-test.GoYLbQ`. No network or host provisioning was used.

## Interfaces and Dependencies

The lifecycle scripts require Bash. Installation targets Ubuntu/WSL and uses Git, `sudo`, APT, and network installers. Updating requires a Git checkout with a configured upstream branch, then delegates provisioning to `installer.sh --dotfiles-dir PATH`; it introduces no new third-party dependency.

Revision note (2026-07-15): Marked implementation complete and recorded validation evidence and the remaining end-to-end environment caveat.
