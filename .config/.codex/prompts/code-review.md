# Codex Code Review Plugin

A Codex-ready workflow definition that reviews pull request diffs from multiple perspectives and keeps only high-confidence findings.

## Capabilities
- Parallel review with multiple agents and confidence scoring
- Filters out findings below a threshold (e.g., 80)
- Checks repository guidelines (`GUIDELINES.md`, `docs/review.md`, etc.)
- Detects diff-introduced bugs and inspects history (git blame)
- Auto-skips drafts, already-reviewed PRs, or trivial changes

## Command to register (example)
- `/code-review`: Review the current branch diff and summarize high-confidence issues

## Example usage
1. Run `/code-review` on the target branch.  
2. The tool summarizes the diff and runs parallel checks.  
3. Only findings with score ≥80 are shown, with file and line references.  
4. If none, it reports “no high-confidence issues.”

## Comment format (example)
```
## Code review

- Missing error handling: OAuth callback swallows errors (auth.ts:67-72)
- Resource leak: session not closed in finally (auth.ts:88-95)
```

## Ops notes
- Keep guideline files fresh before review.
- Lower thresholds increase noise; start around 80.
- Tune skip conditions (draft, already reviewed, trivial) as needed.
- Prioritize severe findings; treat low-confidence items as noise.
