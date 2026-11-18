---
name: frontend-design
description: Design and implement frontend interfaces. Use when building or changing visible UI, including responsive behavior and accessibility.
---

# Frontend Design

Use the requested screen, component, or user flow as the unit of work. Check the existing product, its components and tokens, and any supplied design reference. New pages in an existing product inherit its visual system unless the user asks to change it. When Hallmark also applies, use its visual direction once and carry it through implementation and verification here.

## Design and implementation

- For a new design, choose imagery and typography for the product's audience and primary task. For an existing design, reuse its assets and type scale. Use product screenshots or faithful diagrams to explain known features. Label stand-ins where their status matters. Only use claims, prices, and testimonials supported by the brief.
- Group related information with spacing and hierarchy. Use color consistently for actions, status, and data. Keep copy that identifies content, explains a decision or state, or helps someone act. Match a button label to its effect.
- Implement in the existing framework. Set layout changes where the content stops fitting. Check long Japanese labels, heading breaks, and URLs before shrinking the type. A complex diagram may need a different arrangement at narrow widths.
- Preserve semantic controls, keyboard navigation, visible focus, contrast, usable targets, and reduced-motion behavior. Implement loading, empty, disabled, or error states when the interaction can reach them.

## Verification

Open the affected view at a representative compact and wide width. Compare it with the reference or existing product. Exercise the main interaction and its relevant states, including keyboard use. Check for clipping, overlap, wrapping, and console errors. Run the project's relevant checks, fix issues within scope, and recheck the affected view. Identify any rendered or interactive behavior you could not verify.
