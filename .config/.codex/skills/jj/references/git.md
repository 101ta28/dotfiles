# Git interoperability and publishing

Use this reference for setup, colocated repositories, remote bookmarks, and publishing. Uppercase names are placeholders for inspected values. Read local `--help` when flags differ across versions.

## Setup and colocated repositories

For a requested clone, use `jj git clone URL DEST`. For a requested migration of an existing Git checkout, inspect its Git status and staged/unstaged changes first, then use `jj git init --colocate` in that checkout. Inspect the result with jj. Do not initialize repositories merely to inspect them with this skill.

Choose colocation deliberately using `--colocate` or `--no-colocate` where supported; defaults have changed across releases. Keep an existing workspace's layout unless a change was requested.

In a colocated workspace:

- Git and jj share files and the backing Git repository. jj normally imports and exports Git refs automatically; routine manual `jj git import`/`export` is unnecessary.
- Git's HEAD/index view can differ from jj's working-copy commit. Use `jj status`, `jj diff`, and `jj log` to reason about jj work, and use jj commands for its history changes. If a Git operation is required for a Git-specific tool, inspect jj state again afterward.
- A Git staging boundary does not separate jj's snapshot of the working copy. Preserve the distinction before a requested migration rather than assuming staged paths become a separate jj change.
- Do not assume Git hooks run under jj. Run repository-required validation explicitly. Check installed-version support before relying on Git attributes, LFS, submodules, or Git worktrees; use jj workspaces for additional jj working copies.

Official reference: [Git compatibility](https://docs.jj-vcs.dev/latest/git-compatibility/).

## Fetch and tracking

Inspect `jj git remote list` and `jj bookmark list --all`. Resolve the actual remote and base instead of assuming `origin` or `main`.

`jj git fetch --remote REMOTE` refreshes remote state and can update tracked local bookmarks or expose bookmark conflicts. It does not automatically rebase the user's feature stack. Inspect before choosing any rebase.

`NAME@REMOTE` is the last observed remote position, not necessarily the current server state. For an existing remote bookmark that should be tracked, use `jj bookmark track NAME@REMOTE` after inspecting both local and remote targets. Tracking is separate from advancing a bookmark and from choosing a push remote.

If targets conflict, inspect `jj bookmark list --all` and the competing revisions. Rebase, merge, or select a specific target according to the requested history. `jj bookmark set NAME -r REV` can resolve the target; use `--allow-backwards` only when a backward or sideways move is intended.

Official reference: [bookmarks and remotes](https://docs.jj-vcs.dev/latest/bookmarks/).

## Publish exactly the intended bookmark

A request for local edits or commits does not by itself request a push. If publication is already authorized, complete it without requesting the same permission again. Otherwise prepare the concrete target and preview for approval.

1. Inspect the completed revision by ID. If `jj commit` or `jj new` just created an empty working-copy child, do not publish `@` accidentally. Verify descriptions, tests, conflicts, and the ancestor changes that would be included.
2. Create or advance only the intended bookmark with `jj bookmark set NAME -r REV`. A new child does not automatically advance its parent's bookmark.
3. Preview the explicit target:

   ```sh
   jj git push --remote REMOTE --bookmark NAME --dry-run
   ```

4. Check for unintended creations, deletions, backward moves, or additional changes. Then, within existing authorization, run the same command without `--dry-run` and inspect the reported result and tracking state.

Avoid an unqualified push or broad `--all`/`--tracked` selection for a single-feature request. A bookmark push includes the required ancestors up to the target, even if the target's own diff is small. The dry run previews remote updates; it is not a promise of no local snapshot or metadata activity, and it does not eliminate a race with another remote writer.

In jj 0.46.0, `--remote` can be repeated and accepts remote-name patterns. For a single-destination request, supply one concrete remote name and check every destination shown in the preview; do not expand it to a wildcard or rely on configured defaults.

New-bookmark push syntax varies by version. In the verified jj 0.46.0, explicit `--bookmark NAME` sets up tracking automatically when the bookmark is not tracking any remote yet. If it already tracks another remote, pushing to a new destination can be refused until `jj bookmark track NAME@REMOTE` explicitly establishes tracking for that intended destination. Inspect tracking and the requested destination before making that change, then repeat the dry run. Consult local help rather than blindly adding `--allow-new` from an old example.

jj's push safety checks can permit rewriting an already published bookmark without a separate force flag when the observed remote state matches expectations. Treat the intended history rewrite as part of the authorization decision. If rejected, inspect the reason, fetch the relevant remote when appropriate, and reassess; stop if resolving the mismatch would overwrite others' work or expand the requested scope. Do not bypass conflict, private-commit, or empty-description checks merely to make publication succeed.

## GitHub pull requests

When PR creation is requested, publish the selected bookmark and use the available GitHub tool with an explicit repository, base branch, and head bookmark. Do not rely on automatic current-branch detection from Git's HEAD in a jj workspace. Review the full base-to-head diff and report checks actually run. PR creation remains a separate external write unless the user's request already includes it.

Official workflow reference: [working with GitHub](https://docs.jj-vcs.dev/latest/github/).
