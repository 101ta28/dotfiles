# Codex Execution Plans

An ExecPlan is a self-contained, living design document for a complex feature or significant refactor. It must let a developer who knows only the current working tree implement and verify the change without relying on prior conversation.

## Core Contract

Every ExecPlan must:

- Explain the user-visible purpose and the observable outcome.
- Contain the context, decisions, steps, and validation needed to complete the work.
- Stay accurate as implementation progresses and discoveries change the approach.
- Produce demonstrably working behavior, not merely code that compiles.
- Define unfamiliar terms in plain language.
- Be safe to resume, repeat, and recover after a partial failure.

An ExecPlan may reference files already present in the repository. Do not depend on chat history, unpublished context, or external articles for information required to execute the plan; summarize the necessary knowledge in the plan itself.

## Authoring and Execution

Before writing a plan, inspect the relevant source, repository instructions, tests, and documentation. Resolve ordinary implementation choices in the plan. Ask the user only when an ambiguity would materially change the outcome, risk, cost, or scope.

During implementation, continue through the milestones without asking for routine next steps. Keep the plan synchronized with reality at every stopping point:

- Update `Progress` with completed and remaining work.
- Record unexpected evidence in `Surprises & Discoveries`.
- Record consequential choices in `Decision Log`.
- Revise later steps when discoveries invalidate earlier assumptions.
- Summarize results and remaining gaps in `Outcomes & Retrospective`.

Do not treat the original plan as immutable. The current file must always be sufficient for another developer to resume the work.

## Required Sections

Every ExecPlan must contain these sections:

### Purpose / Big Picture

State what becomes possible after the change, why it matters, and how a person can observe the result.

### Progress

Use timestamped checkboxes. Split partially completed work into explicit completed and remaining portions. This section must reflect the actual state whenever work pauses.

### Surprises & Discoveries

Record findings that affect the design or execution. Include concise evidence such as a test result, log excerpt, or source location.

### Decision Log

Record each consequential decision, its rationale, and the date and author. Include changes of direction.

### Outcomes & Retrospective

At milestones and completion, compare the result with the original purpose. State what works, what remains, and lessons that affect future work.

### Context and Orientation

Describe the relevant current state for a newcomer. Name repository-relative files, modules, and symbols precisely, and explain how they relate. Define non-obvious terms.

### Plan of Work

Describe the implementation sequence in prose. For each change, name the file and relevant location, explain what changes, and state why. Use milestones only when they provide independently verifiable progress.

### Concrete Steps

Give exact commands and working directories. Include short expected outputs where they help distinguish success from failure.

### Validation and Acceptance

Define behavior a person can verify. Name the relevant tests and direct checks, the expected results, and how each proves the requested outcome. For internal changes, explain the regression test or observable scenario that demonstrates the effect.

### Idempotence and Recovery

State which steps are safe to repeat. For risky or interruptible steps, explain retry, rollback, backup, or recovery procedures.

                                                          ### Artifacts and Notes

Include only the short transcripts, diffs, measurements, or snippets needed as evidence. Keep large generated output outside the plan and reference its repository path.

### Interfaces and Dependencies

Name required libraries, services, APIs, types, and function signatures. State compatibility constraints and why each dependency is needed. If none apply, say so explicitly.

## Writing Rules

- Prefer clear prose over long lists and repeated requirements.
- State each instruction and assumption once, in the section where it belongs.
- Use repository-relative paths and exact symbol names.
- Focus on observable outcomes and constraints; avoid prescribing incidental details that can be safely decided during implementation.
- Keep examples only when they prevent a likely mistake or define a required format.
- Use indented blocks for commands, output, and code excerpts inside the plan.
- If the ExecPlan is delivered in chat, wrap the entire plan in one `md` fenced block and do not nest fences. If the file itself contains only the ExecPlan, omit the outer fence.

## Prototypes and Parallel Paths

Use a prototype when a material unknown cannot be resolved by inspection. Define the question, the smallest experiment, the command to run, the evidence to collect, and the criterion for adopting or discarding the result.

Parallel implementations are appropriate when they reduce migration risk or keep the system testable. Explain how both paths are validated, which contracts remain stable, and how the obsolete path will be removed safely.

## ExecPlan Template

    # <Short, action-oriented title>

    This ExecPlan is a living document. Keep `Progress`, `Surprises & Discoveries`,
    `Decision Log`, and `Outcomes & Retrospective` current as work proceeds.
    Maintain this document in accordance with `~/.codex/PLANS.md`.

    ## Purpose / Big Picture

    <User-visible outcome and how to observe it.>

    ## Progress

    - [x] (YYYY-MM-DD HH:MMZ) <Completed step.>
    - [ ] <Remaining step.>

    ## Surprises & Discoveries

    - Observation: <Finding.>
      Evidence: <Test output, log excerpt, or source location.>

    ## Decision Log

    - Decision: <Choice.>
      Rationale: <Why this choice was made.>
      Date/Author: <YYYY-MM-DD, name.>

    ## Outcomes & Retrospective

    <Results, gaps, and lessons.>

    ## Context and Orientation

    <Relevant files, symbols, relationships, and definitions.>

    ## Plan of Work

    <Ordered implementation narrative and independently verifiable milestones.>

    ## Concrete Steps

    <Working directories, commands, and useful expected output.>

    ## Validation and Acceptance

    <Observable behavior, tests, expected results, and success criteria.>

    ## Idempotence and Recovery

    <Safe retries, rollback, backup, and recovery.>

    ## Artifacts and Notes

    <Concise evidence and repository paths to larger artifacts.>

    ## Interfaces and Dependencies

    <Required APIs, types, signatures, services, and compatibility constraints.>

At the end of each revision, add a short note describing what changed and why. Remove stale statements rather than accumulating contradictory history; preserve consequential history in `Decision Log`.
