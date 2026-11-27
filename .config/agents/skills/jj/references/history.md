# History, conflicts, and recovery

Read the section needed for the requested operation. Uppercase names in examples stand for inspected revision IDs, paths, or operation IDs; substitute concrete values.

## Select revisions before rewriting

Preview a proposed revset with `jj log -r 'EXPRESSION'`. Quote expressions so the shell does not interpret their operators. Check the whole selected set rather than choosing an arbitrary first result.

| Revset | Meaning |
| --- | --- |
| `@` | This workspace's working-copy commit |
| `@-` | Its parent(s), possibly more than one |
| `::REV` | REV and its ancestors |
| `REV::` | REV and its descendants |
| `BASE..TIP` | Ancestors of TIP excluding ancestors of BASE |
| `conflicts()` | Revisions with file conflicts |
| `divergent()` | Visible commits sharing a change ID with another visible commit |

Do not assume the default `jj log` includes all relevant history. For a rewrite, inspect its source, destination, and affected descendants explicitly. Before a significant rewrite, record the current operation ID from `jj op log -n 5` so its effects can be inspected or reversed precisely.

A change ID with multiple visible versions needs disambiguation. Inspect `jj log -r 'divergent()'` and use the commit ID of the version you mean. Compare versions with `jj evolog -r COMMIT_ID` or `jj diff --from FIRST --to SECOND` before deciding what to keep. [Revsets](https://docs.jj-vcs.dev/latest/revsets/) and [divergent changes](https://docs.jj-vcs.dev/latest/guides/divergence/).

## Separate or combine changes

Path arguments to `commit`, `split`, and `squash` are filesets. Shell quoting prevents shell expansion, but jj still interprets patterns. To select one literal path from any subdirectory, use a workspace-relative exact match such as `'root-file:"src/test[1].rs"'`. Preview the same selector with `jj diff -r REV --summary -- 'root-file:"src/test[1].rs"'`. [Fileset syntax](https://docs.jj-vcs.dev/latest/filesets/).

- To finish selected whole-file changes from `@`, use `jj commit -m 'message' -- PATH...`. The remaining changes stay in the new working-copy child. Inspect both revisions to verify separation.
- To split a revision by whole files, use `jj split -r REV -m 'selected changes' -- PATH...`. In the ordinary split, the first revision keeps the selected changes. Its child keeps the remainder and receives the bookmarks. With a path-limited `jj commit`, bookmarks stay on the completed parent. Check both diffs and the bookmark targets afterward.
- To move selected changes between existing revisions, use `jj squash --from SOURCE --into DEST -m 'combined message' -- PATH...`. Omit paths only when all changes from SOURCE should move. If retaining DEST's description is intended, `--use-destination-message` avoids an editor on versions that support it.
- Squash normally abandons a source that becomes empty; `--keep-emptied` preserves it when that is part of the requested structure. Inspect bookmarks and the new `@` afterward.
- Whole-file selectors cannot isolate unrelated hunks in the same file. Use a supported diff editor only when an interactive session is available, or a deliberate file-editing workflow that preserves the original contents and verifies both resulting patches. Do not broaden the selected scope just to avoid interaction.

## Rebase with explicit scope

The examples use `--onto`, supported by the verified version. Older versions may use `--destination`/`-d`; check `jj rebase --help`.

| Intent | Command shape |
| --- | --- |
| Move a change and its descendants | `jj rebase --source SOURCE --onto DEST` |
| Move only selected revisions | `jj rebase --revision 'REVSET' --onto DEST` |
| Move a branch relative to the destination | `jj rebase --branch TIP --onto DEST` |

With `--revision`, descendants left behind are rebased onto the removed revisions' parents. With `--source`, multiple selected sources each become direct children of the destination; passing every revision of a stack as a source can flatten it. For a stack, select its root as the source, or use an appropriate `--revision` set to retain dependencies.

Avoid relying on the default source selection: an unqualified rebase can move more history than the user intended. Afterward, inspect the affected graph and `jj log -r 'conflicts()'`, narrowing the latter for a large repository.

## Resolve conflicts

A rebase or merge can finish successfully and leave conflicted revisions. There is no `jj rebase --continue` or Git staging step.

1. Inspect `jj status`, `jj log -r 'conflicts()'`, and `jj resolve --list -r REV`.
2. To review just the resolution, start a child with `jj new REV`, replace the conflict markers with the intended content, and inspect `jj diff`. If the resolution belongs in the mutable parent, run `jj squash --use-destination-message` from that child. To resolve directly in a mutable revision, use `jj edit REV` and edit the file there. Start with the earliest affected ancestor so descendants can inherit the resolution.
3. Check the affected revisions again with `jj log -r 'conflicts()'` and run the relevant project checks.

`jj resolve` without `--list` invokes a merge tool. For an interactive edit, `jj resolve --tool :editor -- PATH` opens the file's markers in the configured text editor and supports conflicts with more than two sides. With direct file edits, jj snapshots the result and retains any unresolved markers. Read diff-style markers as base-to-side changes. A conflicted bookmark instead needs a choice of target revisions.

Official reference: [conflicts](https://docs.jj-vcs.dev/latest/conflicts/).

## Recover an operation

Inspect before changing recovery state:

```sh
jj op log -n 10
jj op show OP_ID
jj --at-op=OP_ID log -n 15
```

Operation IDs belong to the repository operation log, not the commit graph. In `--at-op=OP_ID` inspection, `@` refers to the working-copy commit recorded at that operation, and current file edits are not snapshotted.

- `jj undo` steps back one operation and `jj redo` reapplies the most recently undone operation. Verify the operation first. Snapshots and work from other workspaces share the log.
- To reverse one identified operation while retaining later work, use `jj op revert OP_ID`. Inspect the result for conflicts or dependencies that prevent a clean reversal.
- `jj op restore OP_ID` resets the whole repository view, including bookmarks and working-copy state. Use it only when that broad rollback is intended and authorized; it is not a narrow fix for one bad edit.

Snapshot or otherwise preserve current file edits before a recovery that can replace them. Recovery affects local repository state; it does not retract a remote push. Recheck remote state before publishing after undoing an operation that changed remote-tracking information.

Official reference: [operation log](https://docs.jj-vcs.dev/latest/operation-log/).

## Additional workspaces

When the task benefits from a separate working directory, inspect `jj workspace list` and use `jj workspace add --name NAME -r BASE PATH`. BASE becomes the parent of that workspace's new working-copy commit. Workspaces share history and bookmarks. If a rewrite leaves another workspace stale, run `jj workspace update-stale` there.

When retiring a workspace, `jj workspace forget NAME` leaves its files on disk. `jj workspace remove NAME` also deletes its directory, including ignored files. Use removal only when that deletion is intended. [Working copies and workspaces](https://docs.jj-vcs.dev/latest/working-copy/#workspaces).
