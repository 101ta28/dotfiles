---
name: frontend-design
description: Design and implement frontend interfaces. Use when building or changing visible UI, including responsive behavior and accessibility.
---

# Frontend Design

Build a working interface whose visual choices follow the product context rather than a generic template.

## Establish the direction

- Preserve the existing design system unless the user requests a redesign. Prefer explicit requirements and visual references, then existing tokens, components, and computed styles.
- For greenfield work, choose one coherent direction based on the product's audience, task, and tone.
- Separate content requirements from visual decisions. Do not invent features, prices, testimonials, or results; identify added copy and sample data.
- For open-ended design, compare distinct hero compositions before extending the page when useful. A small UI fix does not need alternatives. Ask the user to choose only when they requested that workflow or the choice materially changes scope.

## Make deliberate visual choices

- **Color:** Start with a focused accent palette. Reserve additional colors for meaningful roles, including statuses and data series; check text against its actual background.
- **Spacing:** Distinguish section gaps, group gaps, and internal spacing so proximity communicates relationships.
- **Typography:** Keep body text readable, establish a clear heading scale, and check Japanese heading breaks at phrase boundaries. Avoid solving overflow by shrinking all text.
- **Composition:** Choose lists, divided rows, diagrams, or cards according to content. Repeated card grids, colored icon containers, and label ornaments need a purpose.
- **Product visuals:** Prefer actual screens or faithful diagrams of known functionality. Keep related imagery consistent. If a UI demo video is requested, consider capturing the implemented interface.
- **Depth and motion:** Use layered shadows selectively to indicate elevation. Give motion a specific role; avoid applying the same reveal everywhere.

Treat these as decision criteria. Cards, familiar fonts, gradients, and flat layouts remain valid when they serve the interface. A reference site's palette, dimensions, decorative effects, and number of alternatives are examples, not universal defaults.

## Implement within the product

- Implement in the repository's framework and reuse shared components and tokens.
- Avoid unnecessary secondary labels and explanatory copy. Make relationships and actions clear through layout, grouping, spacing, and visual hierarchy.
- Define responsive behavior from content constraints, including compact widths, long Japanese text, URLs, and relevant loading, empty, error, and disabled states.
- Preserve semantic structure, keyboard operation, visible focus, sufficient contrast, usable pointer targets, and `prefers-reduced-motion` support.
- Avoid arbitrary gradients, excessive blur or shadows, decorative motion, and interchangeable dashboard or landing-page layouts.
- Keep content visible and usable when animation is disabled. A diagram may need a different arrangement at compact widths rather than proportional shrinking.

## Review the rendered result

- Run relevant static checks and tests. When browser tools are available, inspect representative widths and states, compare supplied references, and check the console. Check clipping, overlap, contrast, keyboard use, and text wrapping in the rendered interface.
- Review visual hierarchy and repetition, fix the highest-impact weaknesses within scope, and inspect the affected views again. Do not invent issues to fill a quota or broaden a small change into a redesign.

State which visual or interactive checks could not be performed.
