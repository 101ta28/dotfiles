---
name: frontend-design
description: Design and implement frontend interfaces. Use when building or changing visible UI, including responsive behavior and accessibility.
---

# Frontend Design

Use the requested screen, component, or user flow as the unit of work. Check the existing product, its components and tokens, and any supplied design reference. New pages in an existing product inherit its visual system unless the user asks to change it. When Hallmark also applies, use its visual direction once and carry it through implementation and verification here.

## Choose what to change

For an existing view, inspect the rendered screen or supplied screenshot when available. Locate each problem and describe its effect on the task. For example, if every row in a jobs list has a bright badge, the failed job that needs attention can be hard to find. If the problem is confined to the status column, fix it there using the existing components and tokens.

For a new design, identify what the person using the screen needs to notice, compare, or do first. Choose a focal point from the product itself. A transcript editor could show the selected passage alongside its matching audio waveform. On a landing page, if the headline and visual could describe an unrelated product equally well, use a specific task or result from the brief to sharpen them.

## Design and implementation

- Establish groups with spacing and alignment before adding borders or cards. Keep a label closer to its value than to the next group. Align repeated icons and labels across rows, and align comparable numbers by place value.
- Give emphasis to the content or action that needs attention. Use color consistently for actions, status, and data, with a visible label or symbol when color conveys meaning. Tone down badges, gradients, or shadows where they compete with that signal. Use motion to show a change, such as a row expanding to reveal its details.
- Set real headings and labels in the project's type scale before adjusting line breaks. For a new visual system, choose type that suits the reading task, from scanning a list to reading a long passage. Name the result of an action on its button. For a metric, make the unit clear and label the baseline for any reported change.
- Reuse the product's assets. Use screenshots or faithful diagrams to explain known features. Keep copy and icons that help people recognize content, interpret a state, or act. Label stand-ins where their status matters. Only use claims, prices, and testimonials supported by the brief.
- Implement in the existing framework. Set layout changes where the content stops fitting. Check long Japanese labels, heading breaks, and URLs before shrinking the type. A complex diagram may need a different arrangement at narrow widths.
- Preserve semantic controls, keyboard navigation, visible focus, contrast, usable targets, and reduced-motion behavior. Implement loading, empty, disabled, or error states when the interaction can reach them.

## Verification

Open the affected view at representative compact and wide widths. For a refinement, compare the same content and state before and after, and check whether the problem you identified is resolved. For a new view, compare it with the brief or reference and check that the information or action people need first is easy to find at both widths.

Exercise the main interaction and its relevant states, including keyboard use. Check for clipping, overlap, wrapping, and console errors. Run the project's relevant checks, fix issues within scope, and recheck the affected view. Identify any rendered or interactive behavior you could not verify.

The guidance on reviewing an existing screen and choosing a product-specific focal point adapts Damir Sokolovsky’s [unslop](https://github.com/heydamir/unslop), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
