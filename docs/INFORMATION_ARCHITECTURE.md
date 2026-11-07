# Candidate Information Architecture

**Status:** Proposed structure for product-owner review; not approved.  
**Platforms:** iOS and Android phones.  
**Locales:** English/LTR and Arabic/RTL.

## 1. IA principles

- The diary is the product's primary workspace.
- Food logging is a global, high-priority action and should be reachable from the main workspace with one obvious action.
- Navigation should expose only a small number of stable destinations.
- AI is initially an input method within food capture, not automatically a separate top-level destination.
- Advanced nutrient detail, data provenance, and settings are progressively disclosed.
- Do not add a tab because a competitor has one. Every top-level destination must represent a recurring user job.
- Route structure must support native back behavior, deep links where relevant, and state restoration without depending on code generation.

## 2. Proposed top-level navigation

| Destination | Primary job | Candidate contents | Status |
|---|---|---|---|
| Today | Understand today's nutrition and log food | Date control, daily summary, meals, add-food action, daily nutrient details | Proposed P0 |
| Progress | Understand changes over time | Weight history, calorie/nutrient trends, summaries | Proposed P1; confirm scope |
| Profile | Manage personal settings and account | Goals, profile, units, language, theme, privacy, account lifecycle | Proposed P0 |
| Add food | Capture a food entry | Search, recent, favorites, barcode, custom food, AI/photo when approved | Global action, not a tab |

**Not proposed as initial top-level tabs:** AI Coach, Recipes, Fasting, Community, Activity, Store. They may be considered later if validated user needs justify them.

### Navigation structure

```text
App
├── Onboarding (only when setup is incomplete)
│   ├── Language / locale
│   ├── Privacy and consent
│   ├── Profile inputs (only those justified by approved goal method)
│   └── Goal setup
├── Main shell
│   ├── Today
│   │   ├── Date selection
│   │   ├── Daily nutrition summary
│   │   ├── Meal groups
│   │   ├── Food entry details
│   │   └── Daily nutrient details
│   ├── Progress (scope subject to approval)
│   │   ├── Weight history
│   │   └── Nutrition trends
│   └── Profile
│       ├── Profile and goals
│       ├── Preferences
│       │   ├── Language
│       │   ├── Theme
│       │   └── Units
│       ├── Privacy and data controls
│       └── Account
└── Global Add Food flow
    ├── Search
    ├── Recent / Favorites
    ├── Barcode scan (after provider/device validation)
    ├── Custom food
    └── AI/photo draft (later, gated by safety and evaluation)
```

## 3. Navigation behavior requirements

- Main destination changes preserve the expected state of each destination. Whether each tab has an independent navigation stack is not decided until interaction prototypes are tested.
- The add-food flow can be opened from Today and contextual meal actions; it must preserve the originating date and meal context.
- Closing or cancelling Add Food returns to the exact prior context without losing the diary scroll position.
- Saving an entry returns to the originating diary context and shows updated totals.
- Back behavior must be consistent with iOS swipe-back and Android system/predictive back.
- A modal or sheet must not trap users; provide visible close/cancel affordances and support system dismissal where appropriate.
- Route parameters are parsed and validated at the app boundary. Do not pass arbitrary mutable objects as the only source of truth for a route.
- Route transitions use centralized motion tokens and reduced-motion alternatives.

## 4. Open IA decisions

1. Whether Progress is a P0 destination or deferred until the diary is validated.
2. Whether the primary add action is a floating action button, a persistent toolbar action, or a contextual action plus one global entry point.
3. Whether Today and Progress require retained independent navigation stacks.
4. Whether recipes/custom foods are part of the first release or later.
5. Whether an AI assistant is a distinct destination at all; do not add it solely because the working product name includes “AI”.
6. Whether the product is Egypt-first or targets a broader Arabic-speaking market.

## 5. Acceptance checks

- A first-time user can identify the primary logging action without explanation.
- A returning user can reach today's diary and add food with minimal navigation.
- Opening and cancelling Add Food preserves the originating diary context.
- Arabic and English navigation labels fit without clipping or ambiguous abbreviations.
- RTL navigation, back gestures, and directional icons behave correctly.
- Screen reader focus order follows the visual hierarchy.
- Reduced motion preserves route comprehension and task completion.
- Top-level destinations are justified by recurring user jobs and validated with usability sessions.
