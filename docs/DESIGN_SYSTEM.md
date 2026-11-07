# Design System and Product Style Guide

## Purpose

This document defines the design-system contract. It is not a final visual brand specification. Brand identity, accent color, font family, and final visual direction remain open until researched and approved. Components must not invent their own styling while those decisions are open.

## Product experience principles

- Calm clarity: show the most useful information first; avoid dashboard density.
- Effortless capture: make adding food the fastest, clearest primary workflow.
- Trust through transparency: distinguish verified catalog data, user entries, and AI estimates.
- User agency: all generated or calculated values are inspectable and editable.
- Progressive disclosure: expose advanced nutrition detail when requested, not all at once.
- Consistency: the same action, state, and component should behave the same way across features.
- Respect: no shame, guilt, manipulative streaks, or punitive language around eating.
- Native fit: preserve familiar iOS and Android behavior for navigation, input, permissions, system surfaces, and back gestures.

## Single source of truth

The implementation must centralize these foundations:

1. Color primitives and semantic color roles.
2. Typography families, roles, weights, line heights, and scaling behavior.
3. Spacing and layout grid.
4. Shape/radius scale.
5. Borders, dividers, and elevation.
6. Iconography and illustration rules.
7. Motion durations, curves, transitions, and reduced-motion alternatives.
8. Component dimensions and interaction states.
9. Theme composition for system/light/dark.
10. Accessibility semantics and touch-target rules.

Feature code must consume semantic tokens and shared components. It must not define local brand colors, arbitrary spacing/radius scales, shadow recipes, or one-off animation durations. A justified exception requires documentation and review.

## Token architecture

Use two levels:

- **Primitive tokens:** raw palette, spacing steps, type scale, radii, elevation, and motion values. These are not referenced directly by feature screens.
- **Semantic tokens:** intent-based roles consumed by components, such as `surface.canvas`, `surface.raised`, `text.primary`, `text.secondary`, `border.subtle`, `action.primary`, `feedback.critical`, and `nutrition.protein`.

Semantic roles must have valid values in every theme. Do not encode meaning only through color; pair status with text/icon/semantics. Nutrition macro colors, if used, must be consistent and distinguishable in all themes and for common color-vision differences.

## Theme contract

- Support system-following, explicit light, and explicit dark selection.
- Theme preference must persist and hydrate before the first meaningful frame to avoid a flash of the wrong theme.
- No screen or shared component may assume a fixed brightness.
- Contrast must be checked for text, icons, borders, focus indicators, disabled states, and data visualization.
- Images and charts must remain legible in both themes.
- Do not implement dark mode as a mechanical inversion of light mode; semantic surfaces and elevation require deliberate values.

## Typography and content

- Choose fonts only after confirming license, Android/iOS rendering, Arabic glyph coverage, weights, numerals, and mixed-script behavior.
- Do not ship Apple's proprietary system font files as cross-platform assets.
- Use semantic text roles (display, headline, title, body, label, caption, numeric/data) rather than arbitrary sizes.
- Use tabular numerals for aligned nutrition totals where supported.
- Allow OS text scaling; layouts must reflow and scroll instead of clipping essential content.
- Arabic copy must be reviewed by a fluent speaker. Avoid concatenated sentence fragments and hardcoded directional punctuation.

## Layout and density

- Design for phone widths and one-handed use where practical.
- Establish a consistent spacing scale and safe-area policy.
- Keep primary actions reachable and visually distinct without competing calls to action.
- Avoid nested cards, card-for-everything layouts, decorative dividers, excessive pills, and dense metric grids.
- Use whitespace to express grouping and hierarchy.
- Do not use fixed heights for text-heavy content unless truncation is intentional, disclosed, and recoverable.
- Design empty, loading, error, offline, and long-content layouts—not only ideal populated screens.

## Component contract

Every reusable component must document:
- Purpose and when not to use it.
- Anatomy and content hierarchy.
- Variants and sizes.
- Semantic token dependencies.
- Default, pressed, focused, selected, disabled, loading, error, and destructive states as applicable.
- Keyboard, screen-reader, focus, and touch behavior.
- Motion and reduced-motion behavior.
- RTL behavior and directional icon handling.
- Tests for state, theme, locale, text scale, and accessibility.

A component belongs in the design system only when it is a stable visual/interaction primitive with multiple consumers. Feature-specific composition stays in its feature.

## Required shared patterns

The system must define consistent patterns for:
- Primary/secondary/tertiary actions and icon buttons.
- Text fields, numeric/decimal entry, search, selectors, and validation.
- Buttons, toggles, segmented controls, checkboxes, radio choices, and sliders.
- Navigation bars, tab navigation, app bars, and back behavior.
- Modal sheets, dialogs, confirmation, and destructive actions.
- Snackbars/toasts and inline feedback.
- Loading, skeleton, empty, error, offline, retry, and permission-denied states.
- Lists, grouped food entries, detail rows, and editable values.
- Charts and nutrition summaries, including accessible text alternatives.
- Date selection, portion selection, and unit conversion.
- Onboarding, consent, and goal setup.

Do not build every pattern before a feature needs it. Define and implement each shared pattern at first real use, then reuse it.

## Motion and perceived performance

- Motion communicates hierarchy, causality, continuity, or state; it is not decoration.
- Keep transitions short and responsive. Never delay a user's action for an animation.
- Support interruption, cancellation, and reversal where appropriate.
- Respect system reduced-motion settings.
- Use haptics only for meaningful committed actions and never as the only feedback.
- Avoid expensive blur, large shadows, repeated layout animations, and unbounded image decoding.
- Establish performance budgets after baseline profiling on representative devices; do not claim smoothness from design intent alone.

## Platform adaptation

Share product logic and semantic design tokens, but adapt platform interactions where users expect them:
- iOS: safe areas, swipe-back, keyboard, text selection, sheets, scroll physics, and permission prompts.
- Android: system/predictive back, edge-to-edge, keyboard/insets, ripple/touch feedback, and permission prompts.
- Do not imitate platform UI indiscriminately. Use Flutter SDK primitives deliberately and wrap them in product-owned components where consistency is required.

## Review matrix

Every shared component and critical screen is reviewed across:
- Light, dark, and system appearance.
- English LTR and Arabic RTL.
- Short and long content, including mixed Arabic/Latin text.
- Default and large text scale.
- Loading, empty, error, disabled, and offline states as applicable.
- Touch, keyboard/focus, screen reader, and reduced motion.
- iOS and Android behavior where the interaction is platform-sensitive.

A clean screenshot is not sufficient acceptance evidence. Interaction, semantics, localization, and failure states must also pass.
