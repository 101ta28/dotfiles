---
name: jj
description: Work with Jujutsu (jj) repositories, including changes, history rewrites, conflicts, bookmarks, and Git remotes. Use when the user requests jj operations or the relevant workspace uses .jj; do not migrate a Git-only repository merely to apply this skill.
---

# Jujutsu (jj)

Use jj's working-copy and change model for the requested repository task. Keep existing work, repository conventions, and the user's intended history intact.

## Establish the workspace

- Check `jj --version` and locate the applicable `.jj` directory, including in ancestors of the current directory. A colocated workspace can have both `.jj` and `.git`; the presence of `.git` alone does not make it a Git-only workflow.
- Run `jj root` to confirm the workspace. If jj is absent or the directory is not a jj workspace, report that fact; installation, cloning, and migration belong only to tasks that request them.
- Inspect `jj status`, `jj diff`, and a bounded `jj log`, such as `jj log -n 15`. Inspect bookmarks or remotes when the task depends on them. Record existing changes before editing.
- Most jj commands, including status and diff, can snapshot working files. For inspection that must avoid snapshotting, use `--ignore-working-copy` and explain that the recorded revision may be stale. To inspect a fixed repository view without merging concurrent operations, use `--at-op=OP_ID` with inspection commands.
- Check the installed command's `--help` before unfamiliar or version-sensitive operations. Core workflows were checked with jj 0.46.0 (build `7d382314f942`); local help takes precedence over examples for another release. Use `--no-pager --color never` when useful for captured output.

## Apply the jj model

- `@` is the current workspace's working-copy commit. File edits amend it when jj snapshots them; there is no Git index or required `git add`. `jj diff` normally compares `@` with its parent(s).
- New nonignored files may be tracked automatically. Check ignore rules before generating output and inspect the resulting file list; an unadded file is not necessarily excluded from a jj change.
- A **change ID** identifies a logical change across rewrites; its **commit ID** identifies one version. Prefer unambiguous change IDs for ongoing work. Use commit IDs when a specific version is intended or a divergent change has multiple versions.
- `jj describe -m 'message'` changes the description and keeps editing the same change. `jj new REV` creates an empty child of `REV` and switches to it. `jj edit REV` instead edits that existing revision, potentially rewriting its descendants.
- `jj commit -m 'message'` describes the current change and creates a new working-copy child when no paths or interactive selection are supplied. Afterward, the completed change is normally `@-`, not `@`. Resolve its ID again instead of carrying stale positional assumptions forward.
- Bookmarks name revisions; there is no checked-out bookmark. They follow rewrites of their target but do not normally advance just because a new child is created. Inspect and move the intended bookmark explicitly when publishing.
- Conflicts can be stored in revisions. A successful command does not establish that the affected history is conflict-free.

See the official [working-copy model](https://docs.jj-vcs.dev/latest/working-copy/) and [bookmarks](https://docs.jj-vcs.dev/latest/bookmarks/) for further explanation.

## Make the requested local change

For ordinary coding, edit files, run the project's relevant checks, and inspect `jj diff` and `jj status`. Automatic snapshots do not require inventing descriptions, splitting history, or creating bookmarks when the user only asked for a code edit.

If asked to prepare commits or reorganize history:

1. Identify the task's changes separately from pre-existing work. Do not describe or commit mixed work as though it all belongs to this task. Use explicit paths when they fully separate the work; changes in the same file may require hunk selection.
2. Choose whether to keep editing `@`, finish it with `jj commit`, create a child with `jj new`, or edit a known mutable change. A child of a user's unfinished change still depends on that change; creating a child does not exclude its ancestors from a future push.
3. Supply messages and revisions explicitly to avoid an unattended editor. For split or squash, consult [history.md](references/history.md) before selecting a noninteractive command. Do not configure a no-op editor that silently accepts an unintended selection.
4. Review the resulting diff and graph, including descendants affected by rewrites. Leave the working-copy revision in the state the user requested and report any remaining conflicts or unrelated work.

Run state-dependent jj mutations sequentially within a repository. Re-resolve IDs and inspect state after a mutation rather than assuming `@`, `@-`, or a bookmark still names the same revision. Avoid bypassing immutable-history protection to make a command succeed; choose a new child unless rewriting that history is explicitly intended.

## Read only the relevant details

- For revsets, split/squash/rebase, conflicts, operation recovery, or additional workspaces, read [history.md](references/history.md).
- For clone/init, colocated Git behavior, remote tracking, push, or GitHub PR preparation, read [git.md](references/git.md).

Prefer the installed `jj help COMMAND` and `jj help -k TOPIC` for exact syntax. The upstream [CLI reference](https://docs.jj-vcs.dev/latest/cli-reference/) and [source repository](https://github.com/jj-vcs/jj) provide additional context; consult documentation matching the installed release when behavior differs.
