# AGENTS.md
# AGENTS.md

## Instruction

Think in English and respond to the user in Japanese.

## ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in ~/.codex/PLANS.md) from design to implementation.

## DESIGN.md Usage

When generating or modifying UI / frontend code, always refer to `.codex/DESIGN.md`.

### Purpose
- Ensure consistency in Japanese UI
- Enforce adherence to the design system

### Scope
- Component design
- Styling adjustments
- UI refactoring

### Rules
- Colors must follow the Color Palette defined in DESIGN.md
- Fonts must use the font-family specified in Typography Rules
- Spacing and layout must follow Layout Principles
- Components must follow Component Stylings
- Japanese text must respect the line-height guidelines in DESIGN.md

### Prohibited
- Introducing colors or fonts not defined in DESIGN.md
- Using body text line-height below 1.5
- Defining font-family without a fallback chain

### Priority
DESIGN.md takes precedence over general best practices

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

## WSL Operations

- When operating on a WSL repository from Codex Desktop on Windows, do not use `\\wsl.localhost\...` as the Codex workspace or shell working directory. It can cause Windows sandbox helper failures such as `helper_unknown_error: setup refresh had errors`.
- Prefer one of these two patterns:
  - Run Codex CLI inside WSL when the task is mainly WSL/Linux repo work.
  - Keep Codex Desktop's workspace on a Windows-local path, then run WSL commands explicitly with `wsl -d <Distro> --cd <LinuxPath> -- sh -lc '<command>'`.
- For WSL commands from Windows, use a Windows-local `workdir` and pass the Linux repo path through `--cd`. Example: `wsl -d Ubuntu --cd /home/tatsuya/KIT-VRM-ChatAgent -- sh -lc 'pwd && rg --files | head'`.
- Do not treat failures from `\\wsl.localhost\...` sandbox setup as repository failures. Retry from a Windows-local workspace with explicit `wsl -d ... --cd ...` before diagnosing the project itself.
- Avoid GUI/browser/Computer Use checks from a WSL UNC workspace. Use a Windows-local Codex Desktop workspace for Browser and Computer Use, and use explicit WSL commands only for Linux-side file, test, Docker, and git operations.
