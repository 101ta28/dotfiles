# AGENTS.md

## Instruction

Think in English and respond to the user in Japanese.

## ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in ~/.codex/PLANS.md) from design to implementation.

## GitHub search tips

- When you find a file on GitHub, replace `https://github.com/<owner>/<repo>/blob/<branch>/<path>` with `https://raw.githubusercontent.com/<owner>/<repo>/refs/heads/<branch>/<path>` to view the raw file directly.
- Example: `https://github.com/101ta28/101ta28-Repo/blob/main/main.py` → `https://raw.githubusercontent.com/101ta28/101ta28-Repo/refs/heads/main/main.py`

### Search termination rule

If repeated searches do not produce a verifiable repository or file after several attempts,
do NOT continue searching indefinitely.

Instead, explicitly determine and state one of the following:

- The repository does not exist
- The repository name is likely misspelled
- The file path does not exist in the repository
- The repository may be private or inaccessible

After stating the most likely conclusion, stop searching and ask the user for clarification
or confirmation before proceeding.

## Markdown policy

- In Markdown, use two trailing spaces at the end of a line only for line breaks within a paragraph.
- Do not add trailing spaces at the end of a paragraph before a blank line.
- When editing or formatting Markdown, do not remove trailing spaces used for intended line breaks.
- After modifying Markdown, verify that intended line breaks have not been collapsed into a single line.
