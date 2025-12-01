# Codex Security Guidance Plugin

A Codex guide to surface security risks early during code edits or automation. Detects dangerous patterns and proposes mitigations and confirmation flows.

## Goals
- Prevent common security failures in commands and code changes
- Flag risky edits and prompt the user for confirmation
- Offer safe alternatives immediately (`--dry-run`, sandboxing, escaping, etc.)

## Patterns to watch
- Command injection (unescaped shell calls)
- XSS/HTML injection (unsafe innerHTML, rendering untrusted input)
- `eval`/`Function` dynamic execution
- Dangerous file ops (`rm -rf`, `dd`, `chmod 777`, etc.)
- Hazardous deserialization (e.g., pickle)
- Secret leakage in outbound requests (tokens, internal URLs)

## Example prompts
- “Check this change for command injection.”
- “Point out XSS risks and suggest sanitization.”
- “Rewrite this delete script to run in dry-run mode safely.”

## Best practices
- Make dangerous actions opt-in via flags or explicit confirmation.
- Prefer input validation and escaping; default to safe behavior.
- Pair each finding with a short rationale and fix (e.g., “Reason: unescaped. Fix: use `shlex.quote`.”).
- Before outbound requests, ensure secrets are not sent; mask if needed.
- State severity and list high-risk findings first.
