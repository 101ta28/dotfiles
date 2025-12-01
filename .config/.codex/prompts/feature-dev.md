# Codex Feature Development Plugin

A Codex workflow for designing, implementing, and validating new features in small phases. Split research → design → build → review into clear steps and leave an artifact at every phase.

## Goals
- Clarify user needs and reduce ambiguity early
- Surface risks and dependencies before coding; validate in small increments
- Keep progress logs and verification results so you can rewind safely

## Example prompts
- “Implement feature A in 5 phases; log decisions and next tasks each phase.”
- “Create a design review summary: assumptions, out-of-scope, risks, test strategy.”
- “In phase 3 implement only error handling and show quick test commands.”

## Example phases
1. Requirements and non-goals  
2. Architecture sketch and data flow  
3. Small PoC/spike to burn down risk  
4. Main implementation plus tests (unit + light E2E)  
5. Retrospective and remaining work (input to next phase)  

## Best practices
- Produce an artifact every phase: decisions, logs, test results.
- Record spec changes and intent in a decision log to keep rationale traceable.
- Even minimal tests should include reproducible commands and expected results.
- If changes can be destructive, warn at the top and default to safe behavior.
- When requesting review, state impact scope (user-facing vs internal only).
