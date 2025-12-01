# Codex Frontend Design Plugin

A Codex skill definition for producing intentional, bold frontend designs—avoiding generic, mass-produced aesthetics while balancing clear visual direction with solid implementation detail.

## Target output
- Distinct palettes and typography (avoid default fonts/colors)
- Meaningful motion (page load, staged section reveals)
- Non-flat backgrounds (gradients, shapes, subtle patterns)
- Layouts that work on desktop and mobile by default

## Example prompts
- “Bold high-contrast landing page for an AI security product.”
- “Music dashboard with heavy typography and staged animations.”
- “Mobile-first settings panel with two accent colors.”

## Guidelines
- Declare purpose/brand tone first, then state palette and fonts that match it.
- Add accent per component; avoid excessive shadows or blur.
- Use a few purposeful motions (section entry, primary actions), not hover spam.
- Avoid flat backgrounds; add depth with gradients/shapes.
- Define responsive behavior up front: breakpoints, spacing, typography sizes.

## Implementation tips
- Centralize colors and type in CSS variables for reuse.
- Respect `prefers-reduced-motion` to allow motion reduction.
- When assets are missing, design layouts that stand with geometry and type alone.
