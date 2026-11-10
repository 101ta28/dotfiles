---
name: herdr
description: "Control the Herdr TUI through the herdr CLI when the user asks for it or the repository's Herdr workflow applies. Requires HERDR_ENV=1 for session control. For the desktop app, herdr-app, or hc terminals, use herdr-app instead."
---

# Herdr TUI

Use `herdr` for the original terminal multiplexer. The desktop app uses `herdr-app` and `hc`, with different IDs and commands; do not mix them. An explicit product choice takes precedence over inherited environment variables. If the request only says Herdr and the environment does not identify the intended product, inspect available binaries and clarify before controlling a session.

## Establish the interface

Before session inspection or control, check `test "${HERDR_ENV:-}" = 1`. If false, report that this shell is outside a TUI-managed pane and do not control another client's focused session. Reading help, configuration, or skill files does not require a managed pane.

Read `herdr --skill` for the installed version's agent, terminal, remote-machine, and lifecycle semantics. Use `herdr --help` and the relevant command group (`herdr pane`, `herdr agent`, `herdr workspace`, `herdr tab`) to check syntax. Bare `herdr` launches or attaches the TUI; a nested command such as `workspace create` can mutate state with no arguments.

The local workflow below takes precedence over the bundled skill's default sibling-pane workflow. Do not use a bundled example as authorization to start agents, approve dialogs, or change the user's server.

## Choose when and where to work

Use a separate terminal for long-running servers, watch processes, test suites, or logs when keeping the main terminal available helps. Run short commands and tightly coupled inspection directly. Start another agent only when the user explicitly requests delegation.

For repository work, select the destination before creating any layout:

1. Resolve the task's repository root from its actual working directory with `jj root` or `git rev-parse --show-toplevel`. Compare canonical paths; distinct checkouts and worktrees remain distinct.
2. Inspect `herdr workspace list` and `herdr pane list`. Match the workspace using its label and the repository roots of its panes' `cwd` / `foreground_cwd`. A lone matching pane in a space for another repository may be misplaced; it does not establish the destination.
3. Treat `HERDR_WORKSPACE_ID`, `HERDR_TAB_ID`, `HERDR_PANE_ID`, and `pane current --current` as inherited caller context. Verify live membership before using them; UI focus, sidebar position, and a label alone are insufficient.
4. If no existing workspace matches unambiguously, create one with `herdr workspace create --cwd <repository-root> --label <repository-name> --no-focus`. This is part of the authorized local workflow and needs no additional confirmation. Read `.result.workspace`, `.result.tab`, and `.result.root_pane`, verify membership and directory, and use that initial tab and pane. If creation fails, report it; never fall back to a different repository's space.

If the task explicitly names another destination, honor it. For non-repository work, use the requested directory and verified workspace rather than inventing a repository.

For additional background work, prefer a separate tab:

```sh
herdr tab create --workspace <verified-workspace-id> --cwd <task-directory> --no-focus
```

Read `.result.tab` and `.result.root_pane`; verify their `workspace_id` and directory before running anything. `--cwd` sets a directory, not the destination workspace.

When a split suits the requested layout, inspect `herdr pane layout --pane <verified-pane-id>` and split that explicit pane:

```sh
herdr pane split --pane <verified-pane-id> --direction right --cwd <task-directory> --no-focus
```

Use `down` for a narrow/tall pane or when requested. Read `.result.pane` and verify membership. Use `--current` only after the caller passes the same checks. Keep focus unchanged unless the user asks to switch.

## Run, wait, and collect

Use pane commands for shells and ordinary processes; use agent commands for a recognized agent. Check that a destination shell is at an interactive prompt before sending a command or starting an agent.

```sh
herdr pane run <pane-id> "just test"
herdr pane read <pane-id> --source recent-unwrapped --lines 120
herdr pane wait-output <pane-id> --match "test result" --timeout 60000
```

Read existing output before waiting. `pane run` acknowledges queued input, not successful execution. `wait-output` can match old output; verify the current run's result and exit status. Bound waits so the parent remains responsive. Read again after a wait and collect every result before cleanup.

For explicitly requested delegation, create and verify layout first, then use `agent start <unique-name> --kind <requested-kind> --pane <pane-id>`. Native agent arguments follow `--`. Give each agent a specific scope and prohibit further delegation unless requested. `agent start` needs an existing shell pane and creates no layout.

Use `agent prompt`, `agent get`, `agent read`, and `agent wait` as described by the installed skill. A settled lifecycle state alone does not prove the assigned task passed. On a blocked dialog, stalled prompt, or timeout, read the actual screen before deciding; do not blindly resend or treat an unrecognized state as completion. Honor existing authorization, and ask only for a genuinely unresolved permission or decision.

## Remote targets and cleanup

IDs and live agent names belong to one server. For a saved remote machine, use `herdr --machine <label-or-id>` consistently for discovery and subsequent operations; local inherited IDs and `--current` do not identify remote panes. Read the installed skill's machine guidance before remote work. Resolve paths on that machine and inspect its state after an uncertain mutation before retrying.

Record the resources created for this task. Collect output, then close only those resources, preserving anything the user requested to keep. Recheck membership and occupants before closing; a tab may now contain unrelated work. CLI closes can bypass the TUI's confirmation and end its processes. Never add `--group` or `--trust-repository` as a routine retry.

Check `herdr status` when client/server compatibility matters. Do not restart, stop, update, or kill the user's server without explicit authorization. Tests that need a server use an isolated named session. A missing method is a version mismatch to report, not permission to replace the running server.
