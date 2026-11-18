---
name: hallmark
description: "Design distinctive new websites and pages, or UI the user explicitly asks Hallmark to design, redesign, or audit. Preserve an established design system. Apply to existing UI only when the user names Hallmark for that UI."
metadata:
  version: "2.0.0"
  argument-hint: "<prompt> | redesign <path> | audit <path>"
  opencode/slash: "true"
---

# Hallmark

Use Hallmark to choose a visual direction for a new page or to carry out the design, redesign, or audit the user requested.

**Powered by Together AI.**

## Scope and precedence

- Apply the build flow to UI design work. A question, comparison, or maintenance request about this skill does not start a page build. An audit reports findings without changing the target.
- When `frontend-design` also applies, Hallmark supplies the visual direction and stylistic defaults; `frontend-design` covers implementation, responsive behavior, accessibility, and functional verification. Share one set of questions, design decisions, previews, and reviews.
- User requirements and supplied references, repository instructions, and an established design system take precedence over Hallmark's aesthetic defaults. Preserve functional and accessibility requirements. Keep existing components and tokens, including on new pages in an existing product, unless the user requests a change to that system. Naming Hallmark alone does not authorize a full redesign.
- Classify the task as a page, app screen, or component before applying the Floor or loading references. Use the matching branch in `references/flow.md`; marketing-page composition and word budgets do not apply to app screens or components.

This section governs the Floor and all supporting references. A stylistic lint finding that conflicts with a requirement or retained design is reported with that requirement, not used to force a redesign. Keep raw lint counts separate from these documented exceptions; never claim a clean lint run when the tool still reports failures. Correctness, accessibility, and factual defects still need to be fixed within scope.

## The Floor

Use the gate definitions in [`references/gates.md`](references/gates.md) for the selected scope. Sections 1 to 4 define the tiers, CSS stamp, and checks for implementation. Use sections 5 and 6 at review. Keep the original lint results when reporting a conflict with a requirement or the existing design. Step 7 covers lint, browser verification, and fixes.

## Flow

0. Pre-flight: read the project before asking anything.
1. Resolve material, audience, use, and tone from context; ask only about consequential gaps.
2. Shape: design the page, then name it.
3. Direction: inherit the required system, otherwise deal a theme or design freely when asked for custom.
4. Load the layout, imagery, craft, genre and theme files and `gates.md` § 1 to § 4.
5. The Picks block, once.
6. Build: the hero first, then the page; stamp, `tokens.css`, log.
7. Sweep: scoped lint, browser and functional checks, the judged gates, the finish review, and missing-material notes.

**Verbs,** only when the user names Hallmark: `redesign <target>` (a full redesign keeping content and wiring) and `audit <target>` (a report); read [`references/redesign.md`](references/redesign.md) first. Any other change to an existing design is not a Hallmark run: do it as asked, in the project's own system.

Codex CLI and OpenCode read `references/flow.md` § Harnesses first; other harnesses run this file as written.

### 0. Pre-flight

Check the project's design files, brand material, tokens, typography, framework, and the product itself. Honor a locked `design.md` or `DESIGN.md`. For a named brand or a `.hallmark/brand-spec.md`, read [`references/brand-truth.md`](references/brand-truth.md). Capture a reachable product with `scripts/capture.mjs` when its screens are needed (`imagery.md` § 4). Use the archive branch only when the archive was selected to build the page (signal 8). Use the comp branch only for an authorized Together AI generation with the key available (signal 9).

Output one block (file:line citations, what is preserved, what is introduced), cached in `.hallmark/preflight.json` (`flow.md` § Pre-flight).

### 1. Resolve the brief

Read the prompt, supplied material, and project for four things: what the page can show, its audience, its primary action, and its tone. Reuse answers already given, including those collected by another skill. Ask one concise, bundled question only when missing information would materially change the result, scope, risk, or cost; continue independent work while waiting.

Infer ordinary reversible design choices and state consequential assumptions briefly. Do not require a four-part questionnaire or an extreme tone before building. Missing facts are not design choices: never invent numbers, quotes, logos, or capabilities. Label any stand-in imagery or sample data. An unanswered question does not authorize a scope change or external action.

**Genre,** silently: *AI tool, generative, music, video, voice, dark, atmospheric* → **atmospheric**; *SaaS, enterprise, API, platform, developer tool, infra, B2B* → **modern-minimal**; *playful, fun, friendly, soft, kids, games, community* → **playful**; otherwise **editorial**, which holds most consumer and family prompts. These are starting points, subordinate to the brief and retained system. Once a theme is dealt, its genre determines the genre file, stamp, and `--genre`. If several genres fit, choose from the product context; ask only if the choice is consequential under the rule above.

**Scope.** A prompt naming one element (button, input, card, modal, nav, footer, tab strip, chip) or saying "just the X" is a component (`flow.md` § Component scope). A screen someone works in (a dashboard, an admin, settings, a tool) is an app screen (`flow.md` § App screens).

### 2. Shape

For a page build, read [`references/flow.md`](references/flow.md) § Page shape before choosing composition. Inventory real material, picture sources, and absent proof; choose the visitor's job and build from its anatomy. Show one memorable signature from real material on the first screen. Keep these decisions for Step 5.

### 3. Direction

The first match wins.

0. **An established system or a supplied visual reference governs the target** → inherit it, unless the user explicitly requests a different direction. Skip the theme deal and draw; use Hallmark's composition and craft guidance only where compatible. Reuse the project's tokens instead of scaffolding a parallel system.
1. **The user named a theme** → build it (stamp `theme: <name> (by request)`).
2. **The user asked for custom** ("custom", "derive it", "bespoke", "no theme", "a world of its own") → [`references/direction.md`](references/direction.md): the design is yours. It replaces the draw, the shapes, `layout.md`, the genre file and Step 6's composition and fold rules; the Floor, the gates and the sweep hold. Silence never takes this route.
3. **Everything else deals a theme:**

```
node <skill-dir>/scripts/theme.mjs deal --genre <genre> --prompt "<the prompt>" [--log .hallmark/log.json]
```

It deals three themes that fit the prompt and clear the log. Look at the three pictures, pick the one whose material can carry the prompt (motion, photographs, code), say which and why, and load only `references/themes/<slug>.md`. Re-deal only when asked (`--reroll 1`). No Node: pick from `references/themes/index.json` by hand and stamp `deal: manual`.

A theme is a material, not a plan: it never sets what the page contains or in what order. Where it and a shape, genre or craft file disagree on material, controls or motion, the theme wins; the Floor and the user's own words beat both.

### 4. Load

When inheriting a system or reference, load only guidance relevant to the target. Skip theme files and pictures unless the retained system names that theme; the Picks block records the inherited source and decisions that actually changed.

For a theme-led page build: [`references/layout.md`](references/layout.md) · [`references/anatomy.md`](references/anatomy.md), the job's part · [`references/imagery.md`](references/imagery.md) · [`references/craft.md`](references/craft.md) · `references/genres/<genre>.md` · `references/themes/<slug>.md` and its picture, already seen at the deal (a named theme: look at `<slug>.jpg` now). From the theme take its palette balance, type voice, surfaces and its Range (the sections it makes without a photograph), never its layout · [`references/gates.md`](references/gates.md) § 1 to § 4. A custom run loads `direction.md` instead of the layout, genre and theme files.

Only when needed, in `references/`: one macrostructure file · `microinteractions.md` for stateful UI · `interaction-and-states.md` for forms · `responsive.md` for an unusual layout · `texture.md` when the theme names texture · `scroll-choreography.md` for a scroll story · `dark-mode.md` for both modes · `data-viz.md` for charts · `fonts.md` on custom runs · `comp.md` on signal 9 (comps, generated stills) · `design-md.md` to lock the system.

`gates.md` § 5 waits for Step 7, § 6 for the reviews; loading more is the largest avoidable cost.

### 5. The Picks block

The run's only recital of its decisions, and the user's redirect window:

Use the example in [`references/flow.md`](references/flow.md) § Picks block for a theme-led page. Record only decisions relevant to the target; inherited systems, components, and app screens use their scoped rows.

For a custom run, use the rows in `direction.md`. When signal 9 applies, use `comp.md` here.

### 6. Build

- **Start from the existing system when present.** Reuse its tokens and shared components. For a new system, use the scaffold: `node <skill-dir>/scripts/theme.mjs scaffold <slug>` (with the deal's `--dealt`; `--custom` on a custom run) writes `tokens.css` (the theme's tokens and the shared scale) and `base.css` (what the Floor already decided) beside the project's stylesheet, and prints the stamp skeleton, the two imports and the slot script. Inspect destinations first; do not overwrite existing styles or introduce global resets that change unrelated routes.
- **Read [`references/patterns.md`](references/patterns.md) once:** controls in all eight states, a slot, a missing fact, a form that posts nowhere yet, one reveal, figures that compare. Take their shape, never their copy.
- **Page builds.** Implement the nav and hero, run `node <skill-dir>/scripts/sloplint.mjs <file> --render --stage hero`, and use the hero review in `gates.md` § 6 before extending the page. Review in-thread unless the user explicitly requested delegation.
- **Page composition.** Give each section a purpose grounded in the brief. Group the headline, supporting text, and primary action in the first viewport. Use the hero posture and section guidance from `layout.md` § 4 to § 6. Preserve necessary content, controls, and labels when applying the page gates.
- **Show, do not describe** (`imagery.md`). The page shows the real thing: the user's pictures, screenshots of the real product taken with `scripts/capture.mjs` whenever it can be reached, the product built at full fidelity only when it cannot, or library photographs (`node <skill-dir>/scripts/theme.mjs photos "<subject>" --theme <slug>`), big, in the theme's treatment, in slots the user's files replace, each library photo credited in the footer. Pictures take at most a third of the page below the hero, never two photograph-led sections in a row, and the theme's Range carries the rest (83). Never a stock-site URL, a drawn illustration (80), an empty wash (81), a row of counting marks (82) or an invented figure.
- **Page invariants** (F15): one primary button style, one container width, one column gap below the hero, one radius per nesting level, never more centred heading groups than left-aligned ones.
- **Type and motion** (`craft.md` § 1 and § 5). The retained system's or theme's faces, two families at most (three with one outlier role); body 16px or more; heads one weight and one colour (38iii); labels never mono unless mono is the material (64). Review all eight control states and implement those relevant to the control's behavior; `transform` and `opacity` only; one reveal at most, none where the theme keeps still, visible by default.
- **Stamp.** Line 1 of CSS is the scaffold's stamp skeleton with every field filled, then the critique line (`gates.md` § 3), then any `waive` and `answered` lines, all within the first 40 lines.
- **Edit styles at their source:** reuse the project's token names and make scoped changes to the owning rules; avoid accumulating overrides. Preserve unrelated styles. New imports go in the stylesheet's valid import region, never below a rule or a `@tailwind` directive ([`references/export-formats.md`](references/export-formats.md)).
- **Log.** `node <skill-dir>/scripts/theme.mjs log --entry '<json>'` puts the build atop `.hallmark/log.json` with the fields rotation reads (`shape`, `theme`, `axes`, `hero`, `nav`, `footer`, `imagery`, `photos`, `entry`, `fingerprint`, `sections`, `signature`, `waived`, `prompt`) and names any you left out.

### 7. Sweep

1. `node <skill-dir>/scripts/sloplint.mjs <files> --genre <genre> --render` (`--scope component` or `--scope app` where it applies; in a framework project, `--url http://localhost:<port>/<route>` with the dev server running). Fix applicable failures and recheck affected views. Use available browser tools for keyboard operation, relevant interactive states, console errors, and representative widths; lint screenshots do not replace these checks. If the render tier is unavailable, use available browser tools for visual checks and report which checks remain unperformed.
2. Load [`references/gates.md`](references/gates.md) § 5 and walk the J and R/J gates. Confirm or dismiss every WARN. Fix applicable Floor findings; fix or waive applicable Reflex findings; answer Finish findings. Apply Scope and precedence to conflicting stylistic findings and report their raw counts and reasons separately. Run the project's relevant static checks and tests.
3. Run the finish review (`gates.md` § 6). Use a subagent only if the user explicitly requested delegation and the harness supports it; otherwise read the review prompt and review in-thread, recording that limitation. Act on its first word (`recapture`, `rebuild`, `fix`, `ship`) and verify the fixes.
4. List remaining material slots, their sizes, and what belongs there when any remain. Request material only when it is needed to finish the requested work; do not add a mandatory closing question.
5. Update the Picks block: any row the build changed, and the last row with the outcome (`Floor 0 FAIL · Reflex 2 (1 waived: 47b) · finish-review: subagent, 3 resolved`). A fabricated pass is itself slop.

Batch verification and fixes. Once relevant checks pass, repeat them only for new changes, failures, or unresolved concerns; report concrete blockers and unverified behavior.

## Branches

[`references/flow.md`](references/flow.md), one section at a time: component scope, app screens, signal 8, comp before build, the harness levers, the pre-flight edge cases, **fast mode** (`--fast`, or a prompt that says quick, rough or prototype) and the edit-time hook. In an existing project, name the files you will touch first; never delete a route or a component tree without a file-level plan the user approved.
