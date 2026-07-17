---
name: frontend-design
description: Build or revise production frontend components, pages, and applications with an intentional visual direction, responsive behavior, and accessibility. Use for UI implementation; preserve an existing design system unless the user asks for a redesign.
---

# Frontend Design

Build a working interface whose visual choices follow the product context rather than a generic template.

- Preserve the existing design system unless the user requests a redesign. Prefer explicit requirements and visual references, then existing tokens, components, and computed styles.
- For greenfield work, choose one coherent direction based on the product's audience, task, and tone.
- Implement in the repository's framework and reuse shared components and tokens.
- Define responsive behavior from content constraints, including compact widths, long Japanese text, URLs, and relevant loading, empty, error, and disabled states.
- Preserve semantic structure, keyboard operation, visible focus, sufficient contrast, usable pointer targets, and `prefers-reduced-motion` support.
- Avoid arbitrary gradients, excessive blur or shadows, decorative motion, and interchangeable dashboard or landing-page layouts.
- Run relevant static checks and tests. When browser tools are available, inspect representative widths and states, compare supplied references, and check the console.

State which visual or interactive checks could not be performed.
