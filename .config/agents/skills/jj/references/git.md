# Git interoperability and publishing

Use this reference for setup, colocated repositories, remote bookmarks, and publishing. Uppercase names are placeholders for inspected values. Read local `--help` when flags differ across versions.

## Setup and colocated repositories

For a requested clone, use `jj git clone URL DEST`. For a requested migration of an existing Git checkout, inspect its Git status and staged/unstaged changes first, then use `jj git init --colocate` in that checkout. Inspect the result with jj. Do not initialize repositories merely to inspect them with this skill.

`jj git init` and `jj git clone` create colocated workspaces by default in 0.47.1. The `git.colocate` setting changes the default. Use `--colocate` or `--no-colocate` if the task requires a particular layout.

In a colocated workspace:

- Git and jj share files and the backing Git repository. jj normally imports and exports Git refs automatically; routine manual `jj git import`/`export` is unnecessary.
- Git HEAD normally points to the first parent of `@`. Inspect `jj diff` for the whole working-copy change and `git diff --cached` for the staged part. jj snapshots working files regardless of what was staged.
- In 0.47.1, snapshotting and `jj describe -r @` preserve an existing Git staging selection. Changing the working-copy parent with `jj new @-` can reset it. If staged work must survive a migration or checkout, inspect and preserve the selection first.
- Do not assume Git hooks run under jj. Run repository-required validation explicitly. Check installed-version support before relying on Git attributes, LFS, submodules, or Git worktrees; use jj workspaces for additional jj working copies.

In a non-colocated workspace, `jj git fetch` and `jj git push` update jj's remote bookmarks. Since 0.47 they leave the backing Git repository's remote-tracking refs alone. Use `jj bookmark list --all` to inspect jj's view. If a Git-only consumer needs those refs updated, `jj git export` copies jj's refs to the backing repository. [Git compatibility](https://docs.jj-vcs.dev/latest/git-compatibility/) and [release notes](https://docs.jj-vcs.dev/v0.47.1/changelog/).

## Fetch and tracking

Inspect `jj git remote list` and `jj bookmark list --all`. Resolve the actual remote and base instead of assuming `origin` or `main`.

`jj git fetch --remote REMOTE` refreshes remote state and can update tracked local bookmarks or expose bookmark conflicts. It does not automatically rebase the user's feature stack. Inspect before choosing any rebase.

`NAME@REMOTE` records the last observed remote position. A clone tracks the remote's default bookmark. Other bookmarks fetched later normally require explicit tracking unless `remotes.<name>.auto-track-bookmarks` matches them. To follow an existing bookmark, inspect both targets, then use `jj bookmark track NAME@REMOTE`. Use `jj bookmark list --tracked` to inspect tracking and `--remote REMOTE` on the push to choose its destination.

If targets conflict, inspect `jj bookmark list --all` and the competing revisions. Rebase, merge, or select a specific target according to the requested history. `jj bookmark set NAME -r REV` can resolve the target; use `--allow-backwards` only when a backward or sideways move is intended.

Official reference: [bookmarks and remotes](https://docs.jj-vcs.dev/latest/bookmarks/).

## Publish exactly the intended bookmark

A request for local edits or commits does not by itself request a push. If publication is already authorized, complete it without requesting the same permission again. Otherwise prepare the concrete target and change summary for approval.

1. Inspect the completed revision by ID. If `jj commit` or `jj new` just created an empty working-copy child, do not publish `@` accidentally. Verify descriptions, tests, conflicts, and the ancestor changes that would be included.
2. Create or advance only the intended bookmark with `jj bookmark set NAME -r REV`. A new child does not automatically advance its parent's bookmark.
3. Compare the intended bookmark with its remote-tracking target and review the included revisions for unintended creations, deletions, backward moves, or additional changes. Within existing authorization, execute the push directly:

   ```sh
   jj git push --remote REMOTE --bookmark NAME
   ```

4. Inspect the actual push result and tracking state before reporting completion. Setting a description or moving a local bookmark does not complete a push request.

Do not add `--dry-run` as a routine prerequisite. Use it only when the user explicitly requests a preview or simulation. A preview alone does not complete an authorized push: if the user requests both a preview and publication, inspect the preview and then execute the actual push. A dry run may still snapshot the working copy or update local metadata, and it does not eliminate a race with another remote writer.

Avoid an unqualified push or broad `--all`/`--tracked` selection for a single-feature request. A bookmark push includes the required ancestors up to the target, even if the target's own diff is small.

Both `--remote` and `--bookmark` accept glob patterns in 0.47.1. For a single target, pass its concrete name. Use the `exact:` prefix if that name contains pattern characters.

An explicit `--bookmark NAME` can create and track a new remote bookmark when the local bookmark tracks no remote yet. If it already tracks another remote, inspect the intended destination and use `jj bookmark track NAME@REMOTE` when tracking there is also intended. Then retry the scoped push.

jj's push safety checks can permit rewriting an already published bookmark without a separate force flag when the observed remote state matches expectations. Treat the intended history rewrite as part of the authorization decision. If rejected, inspect the reason, fetch the relevant remote when appropriate, and reassess; stop if resolving the mismatch would overwrite others' work or expand the requested scope. Do not bypass conflict, private-commit, or empty-description checks merely to make publication succeed.

If signing on push is configured, jj signs matching mutable commits in a separate local operation before pushing. A failed push can therefore leave signed commits with new commit IDs. Re-read the bookmark target before retrying. In 0.47.1 the setting is `revsets.git-sign-on-push`. [Signing configuration](https://docs.jj-vcs.dev/latest/config/#automatically-signing-commits).

## GitHub pull requests

When PR creation is requested, publish the selected bookmark and use the available GitHub tool with an explicit repository, base branch, and head bookmark. Do not rely on automatic current-branch detection from Git's HEAD in a jj workspace. Review the full base-to-head diff and report checks actually run. PR creation remains a separate external write unless the user's request already includes it.

Official workflow reference: [working with GitHub](https://docs.jj-vcs.dev/latest/github/).
