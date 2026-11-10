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

Do not assume the default `jj log` includes all relevant history. For a rewrite, inspect its source, destination, and affected descendants explicitly. Before a significant rewrite, record the current operation ID from `jj op log -n 5` so its effects can be inspected or reversed precisely.

Official reference: [revsets](https://docs.jj-vcs.dev/latest/revsets/).

## Separate or combine changes

- To finish selected whole-file changes from `@`, use `jj commit -m 'message' -- PATH...`. The remaining changes stay in the new working-copy child. Inspect both revisions to verify separation.
- To split a revision by whole files, use `jj split -r REV -m 'selected changes' -- PATH...`. In the ordinary split, selected changes stay in the first revision and the remainder becomes its child. In jj 0.46.0, split moves bookmarks to the remainder child, whereas commit keeps them on the completed revision; check their targets afterward.
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
2. For a mutable conflicted revision, use `jj edit REV` when the task calls for repairing it, then edit the materialized conflict markers. Prefer resolving the earliest affected ancestor so the resolution propagates through descendants.
3. Run `jj status` to snapshot the resolution, inspect the revision's diff and remaining conflicts, and run the relevant project checks. Revisit descendants if conflicts remain.

`jj resolve` without `--list` invokes a merge tool. Direct file editing is appropriate when no usable interactive tool is available. Interpret jj's diff-style markers as base-to-side changes; do not blindly treat every section as Git-style ours/theirs. Bookmark conflicts are distinct from file conflicts and require inspecting the competing target revisions before selecting a target.

Official reference: [conflicts](https://docs.jj-vcs.dev/latest/conflicts/).

## Recover an operation

Inspect before changing recovery state:

```sh
jj op log -n 10
jj op show OP_ID
jj --at-op=OP_ID log -n 15
```

Operation IDs belong to the repository operation log, not the commit graph. In `--at-op=OP_ID` inspection, `@` refers to the working-copy commit recorded at that operation, and current file edits are not snapshotted.

- `jj undo` is suitable only after verifying that the operation it will undo is the intended one. Snapshots or intervening work can change what is latest; do not repeatedly undo by guesswork.
- To reverse one identified operation while retaining later work, check the installed help and use `jj op revert OP_ID`. Older releases may expose a different operation-specific undo interface. Inspect the result for conflicts or dependencies that prevent a clean reversal.
- `jj op restore OP_ID` resets the whole repository view, including bookmarks and working-copy state. Use it only when that broad rollback is intended and authorized; it is not a narrow fix for one bad edit.

Snapshot or otherwise preserve current file edits before a recovery that can replace them. Recovery affects local repository state; it does not retract a remote push. Recheck remote state before publishing after undoing an operation that changed remote-tracking information.

Official reference: [operation log](https://docs.jj-vcs.dev/latest/operation-log/).

## Additional workspaces

When the task benefits from a separate working directory, inspect `jj workspace list` and use `jj workspace add --name NAME -r BASE PATH`. The revision argument selects the parent of a new working-copy commit, not an existing commit to edit directly. Workspaces share repository history and bookmarks, so they do not isolate history rewrites. Inspect state and use `jj workspace update-stale` when jj reports a stale workspace; do not repair it with a Git reset or delete a user's workspace.
