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


## Motion, transitions, effects, and microinteractions (required)

Motion is part of the product's interaction language. The goal is not to animate everything; the goal is to make every meaningful interaction feel responsive, coherent, understandable, and polished.

### Motion principles

- **Purpose before spectacle:** every animation must communicate feedback, hierarchy, continuity, cause/effect, or state. If it does none of these, remove it.
- **Immediate response:** acknowledge user input promptly. Never make users wait for an animation to finish before they can continue.
- **Continuity:** use spatially coherent transitions when moving between related content or navigation levels.
- **Consistency:** the same interaction pattern uses the same motion contract across the app.
- **Restraint:** keep effects subtle and avoid competing with food, nutrition values, and primary actions.
- **Control:** animations should be interruptible and reversible where that improves usability; preserve user input and state during transitions.
- **Accessibility:** respect the operating system's reduced-motion preference and provide a meaningful alternative without loss of information or functionality.
- **Platform fit:** adapt gestures, navigation transitions, sheets, feedback, and system surfaces to iOS and Android conventions.

### Motion inventory and specification

Before implementation, document the motion for each relevant journey/component, including:

- App launch and first-frame/theme restoration (avoid wrong-theme flashes).
- Screen navigation, nested routes, back navigation, and shared-element-like continuity where justified.
- Modal sheets, dialogs, menus, and overlays: entrance, exit, drag/dismiss, and interruption.
- Button press, icon-button press, selection, toggles, segmented controls, and focus.
- Text fields: focus, validation, helper/error text, and keyboard/inset changes.
- Food search: query feedback, loading, result updates, empty state, and selection.
- Diary add/edit/delete/reorder: insertion/removal, totals recalculation, undo, and confirmation.
- Calorie and macro progress changes: value transitions that remain readable and do not misrepresent estimates.
- Charts and progress history: reveal/selection/tooltip behavior and accessible non-animated alternatives.
- Loading, skeleton, success, error, offline, retry, and permission states.
- Haptic feedback for meaningful committed actions, where supported and appropriate.

Each specification records: user trigger; intent; start/end state; properties animated; duration and easing/physics; interruption/cancellation/reversal; reduced-motion behavior; RTL implications; iOS/Android differences; performance risk; and verification method. Do not invent a universal duration before testing; define a small coherent token scale and tune it using real device evaluation.

### Effects and rendering constraints

- Blur, gradients, shadows, parallax, particle effects, animated backgrounds, and image transitions require a clear purpose and measured cost.
- Avoid expensive or broad blur, unnecessary opacity/layer stacking, continuously repainting effects, and animations that trigger repeated expensive layout.
- Prefer transform/opacity or other efficient compositing when appropriate, but profile actual implementation rather than assuming an optimization.
- Never communicate nutrition correctness, urgency, or health status through animation alone.
- Do not use motion to shame, pressure, or manipulate users into logging.

### Required motion documentation

Maintain a motion token table and a motion/interaction inventory as the implementation grows. Every shared component entry must identify its states and motion contract. Feature-level motion belongs in the feature's UX/implementation documentation and must use shared tokens unless an exception is justified and recorded.

When changing motion behavior, update this document, relevant feature specifications, tests, and screenshots/video evidence where useful in the same pull request. Documentation must describe shipped behavior, not aspirational behavior.

### Motion acceptance checklist

- All meaningful interactive states have documented feedback.
- Motion is consistent with shared tokens and component contracts.
- Reduced-motion behavior is tested and preserves task completion.
- Navigation, sheets, keyboard/insets, and back gestures are verified on iOS and Android.
- RTL transitions and directional elements are reviewed; meaningful content is not blindly mirrored.
- No animation blocks input or delays essential actions.
- Profile/release-mode traces on representative devices show no unacceptable jank; measured results and device/build details are recorded.
- Effects are reviewed for battery, thermal, accessibility, and rendering cost.


## Required motion coverage for all newly added journeys

- Food scan, barcode, label, gallery, voice, and manual-entry flows must each define interaction states and feedback.
- Scan overlays, camera focus indicators, recording states, waveform/voice capture, progress, result transitions, editable draft presentation, and save confirmation must use shared motion tokens.
- Animation must never imply that an AI estimate or barcode match is verified.
- Respect iOS Reduce Motion and Android system animation preferences; keep capture and review fully usable without non-essential motion.
- Motion specs, tokens, state diagrams, and tests must be updated in the same PR as behavior changes.
