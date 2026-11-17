---
name: herdr-app
description: "Operate the Herdr desktop app's spaces, tabs, panes, layouts, keys and mods, and its herdr-core (hc) terminals. Use when the user requests herdr-app or hc, or the configured workflow applies inside HC_TERMINAL_ID. The older herdr TUI has a separate skill."
---

# Herdr app and core

`herdr-app` controls the window; `hc` runs and coordinates its terminals. Keep the TUI's repository targeting, scoped delegation, result collection, and cleanup rules while using the app's own interfaces.

## Select the product and read its current contract

- An explicit request for the desktop app or `hc` selects this skill. `HC_TERMINAL_ID` identifies a core terminal; `HERDR_ENV=1` identifies the older TUI. These can be inherited through nesting, so neither overrides the user's product choice. Do not send `herdr` commands to app resources.
- A request to operate the app or core already authorizes using that product, including from a shell outside it. Do not require `HERDR_ENV=1`. If neither context nor the request selects a product, clarify before changing a running session.
- Read `herdr-app --skill` before window operations and `hc --skill` before terminal operations. Check `herdr-app commands` and `hc <command> --help` for exact arguments. The local workflow in this skill governs tool selection and authorization; bundled examples do not authorize delegation, trust decisions, installation, or updates.
- Do not launch bare `herdr-app` or `hc` for discovery: they open/raise the window or attach a terminal. `herdr-app commands` works without a window; `ls` and `status` inspect a running one. Honor `HERDR_APP_HOME` and the selected core/machine context consistently.

The command boundaries below were checked against the [herdr-app 0.1.16 commands](https://raw.githubusercontent.com/herdrdev/herdr-app/refs/tags/v0.1.16/docs/commands.md) and [hc 0.1.21 commands](https://raw.githubusercontent.com/herdrdev/herdr-core/refs/tags/v0.1.21/docs/commands.md). Check installed help before using version-specific arguments; reading these references does not authorize an upgrade. On WSL, the window may be controlled by `herdr-app.exe` on Windows while `hc` runs in WSL; resolve the app's machine mapping rather than treating Windows and WSL as the same local machine.

## Choose direct execution, a split, or a tab

Choose where the work belongs before launching it:

| Work | Execution and placement |
|---|---|
| Short inspection, a brief setup command, or a quick check whose result is needed next | Run directly with the shell tool; no new core terminal or app layout. |
| Related work whose output should be seen alongside the current task, such as a dev server, watcher, live log, or terminal browser | Split the verified task pane. Reuse a task-created idle pane when appropriate. |
| Independently monitored work, or work needing a full terminal, such as a large browser download, a lengthy build, or a test suite | Create a named tab in the verified repository space. Use `--focus false` to leave the person's current view selected. |
| Explicitly requested hidden execution, or work in a core-only environment | Use `hc run --bg --cwd ...` without layout labels. If the app was expected but is unavailable, report that limitation; do not silently substitute hidden execution. |

This user's workflow authorizes routine task-local tabs and splits; the bundled manual's "only create them when asked" does not require another request for each one. Do not launch a separate terminal solely because a command is an install or test, or because the shell tool can yield while it runs. `--bg` controls waiting, not app placement. A terminal address and an `<hc>...exited...</hc>` note prove neither that a pane was created nor that its result was reviewed.

App 0.1.16 supports `--focus false` on `space.new` and `tab.new`, not on `pane.split` or `terminal.open`. With no space shown, a new space is still shown. On older versions, omit unsupported arguments and account for the focus change; never substitute the TUI's `--no-focus` flag. Start subagents only on the user's explicit request; scope their work, collect their results, and review integration.

For process/agent orchestration, read [references/core-work.md](references/core-work.md). For settings, keys, layouts, or mods, read [references/customization.md](references/customization.md).

## Match the task's repository before arranging the window

1. Resolve the repository root from the task's working directory with `jj root` or `git rev-parse --show-toplevel`. Canonicalize paths on the target machine. Different checkouts/worktrees and different machines are separate destinations.
2. Read `herdr-app ls` and `herdr-app status`. Use `hc get <terminal-address>` when needed to inspect `foreground.cwd` (current directory) and `cwd` (launch directory). Inspect several terminals when the space identity is ambiguous; its displayed name or one misplaced pane is insufficient evidence.
3. Match the space's machine and its terminals' repository roots. `HC_TERMINAL_ID` is a terminal address, not a pane or space ID, and its parent context may belong to another repository. Use IDs returned by live discovery, never sidebar positions or inherited TUI IDs.
4. When separate visible work is needed, if no space matches unambiguously, create a named space at the repository root and use its initial tab. No separate confirmation is needed. Otherwise use a split or tab in the verified space according to the table above. A failed lookup or create must not fall back to another repository's focused space.

For local work, use an explicit local machine selector when creating a space:

```sh
herdr-app do space.new --name <repository-name> --folder <repository-root> --tab <task-name> --machine '' --focus false
herdr-app do tab.new --space <verified-space-id> --folder <task-directory> --name <task-name> --focus false
```

These are alternatives: creating a space already creates its first tab. Parse the returned IDs and inspect `ls` plus the terminal's actual directory before sending work. For remote work, use the configured machine name and a path on that machine.

For a split, use `pane.split --pane <verified-pane-id> --direction right` (or `down` for the intended geometry). Confirm its source pane belongs to the intended space and directory. Version 0.1.16's `pane.split` has no `folder` argument. `terminal.open --folder <path> --place down` can set a folder but targets focus; use it only when that focus is the verified destination. If a suitable source pane is unavailable or splitting would make the output unreadable, use a tab with an explicit space and folder.

The commands above create a shell. After checking the returned terminal's membership, directory, and readiness, start the work in that same terminal. For a task-created Unix shell dedicated to a build, for example:

```sh
hc send <returned-terminal-address> 'exec npm run build'
```

Use the task's actual program and quote for the target shell. Replacing this task-created shell with `exec` makes the terminal's exit code the program's result; do not replace a user's existing shell. If a shell must remain open, record and read the command's exit status explicitly: `hc wait` on a live plain shell does not detect a command returning to its prompt. Do not create an empty pane and run the real work in a separate unlabeled `hc run --bg` terminal. Use `hc get/read/wait` on the app-created terminal address to collect results.

App commands return created IDs or an error; a launch reply is not proof that its program started successfully. Inspect both app membership and core state. Pass target IDs as strings and supply required arguments; agent-invoked commands do not open missing-argument dialogs.

## Preserve app-specific behavior

- A pane can host a terminal or a mod. A focused composition terminal block can have no model pane. Never turn a terminal address into a pane ID or act on an implicit source pane; inspect the current layout.
- Use `herdr-app commands` for features such as `pane.swap`, `terminal.peek`, `terminal.search`, `terminal.pin`, and `tab.settle`. `settle` puts a tab away on this screen without ending its work; visibility depends on the layout/mod.
- `terminal.keep` gives a hidden terminal a pane and enables recovery; `terminal.park` removes its pane and disables recovery while leaving it running. They may acknowledge with `pending: true`; verify the applied state or error. Core `--keep` recovers a lost program with a shell, never reruns the task.
- `herdr.space` and `herdr.tab` labels opt terminals into the app; unlabeled `hc run --bg` workers stay hidden even when they appear in the agents list. Prefer app commands for a chosen tab or split. If labels are needed, verify both IDs first: unknown IDs can create new layout. Remote app IDs have a machine prefix, while labels use IDs local to that machine.
- Remote execution/files use `hc run --on`, `hc exec --on`, and `hc file ... --on`; carry returned machine-qualified addresses through later calls. A remote space's folder is on that machine. Never substitute local file tools or TUI `--machine` syntax.

## Finish without disturbing other work

Track created terminal, pane, tab, and space IDs. Read results before cleanup; preserve resources the user wants to keep. Recheck live membership before closing a task-created container that may have gained unrelated work.

Closing the app window leaves core terminals running. Closing a terminal pane/tab/space ends its terminals; it is not a way to hide them. Use `hc kill` / `hc rm` only for the task's own terminals after collecting results, or for explicitly requested termination. Do not stop/restart the app or core, reset settings, update software, or replace remote identities as routine recovery.

On failure, inspect `herdr-app status`, `hc get`, and `hc read` as applicable. A timeout or lost reply may follow an applied action; inspect before retrying. Tests requiring a core use an isolated `HC_SESSION` and scratch configuration. Report remaining resources or unverified behavior precisely.
