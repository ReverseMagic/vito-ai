# Engineering Architecture and Design Patterns

## Intent

Use a small set of explicit patterns consistently. The architecture should make ownership, data flow, and change impact easy to understand. Do not apply patterns mechanically or add layers without a concrete reason.

## Feature-first organization

Features own their user-facing capability and implementation. A feature should not import another feature's private implementation.

Proposed shape when justified:

```
lib/
  app/
    app.dart
    router/
    providers/
  core/
    config/
    errors/
    logging/
    network/
    storage/
  design_system/
    tokens/
    theme/
    components/
    motion/
  l10n/
  features/
    food_log/
      models/
      data/
      presentation/
        providers/
        screens/
        widgets/
      domain/             # only when meaningful rules justify it
```

This is a boundary guide, not a demand to create empty folders. Keep a feature simple until its complexity requires additional structure.

## Dependency direction

- App composition may depend on features and shared infrastructure.
- Features may depend on their own implementation, core infrastructure contracts, localization, and the design system.
- Core infrastructure must not import app composition or feature UI.
- Design-system code depends on Flutter/Dart SDK primitives, not product features or backend SDKs.
- Feature A must not reach into Feature B's internal files.
- Cross-feature navigation uses app-owned route contracts.
- Shared business capabilities belong in a deliberate shared domain module only when genuinely reused.

Enforce boundaries with import checks/tests when the project structure is established.

## Presentation / data separation

**Presentation**
- Widgets render state and send user intent.
- Riverpod Notifiers own feature UI/application state.
- No direct database, HTTP, filesystem, or backend SDK calls from widgets.
- No raw backend response maps in widgets or Notifiers.

**Data**
- Repositories own fetching, persistence, caching, pagination, and data-source coordination.
- Data sources wrap external systems such as Supabase, local SQLite, barcode APIs, or food catalogs.
- DTOs and provider-specific types remain inside data.
- Mapping to feature-owned immutable app models happens at the data boundary.
- Parsing of untrusted JSON must validate types, nullability, units, and malformed values explicitly.

**Domain**
- Use for meaningful business rules such as nutrition calculations, serving conversions, goal calculations, or conflict resolution.
- Pure business logic should not depend on Flutter widgets or infrastructure SDKs.
- Do not create a use-case class that merely forwards one repository call.
- Keep nutrition math deterministic and testable.

## Riverpod conventions

- Use manual Riverpod providers and Notifier/AsyncNotifier APIs compatible with the verified pinned version.
- One authoritative provider owns each state value.
- Use `ref.watch` for reactive UI dependencies; use `ref.read` for explicit commands/callbacks.
- Use `ref.listen` for effects such as navigation and transient messages, not build-time side effects.
- Scope providers deliberately; screen-scoped state should not leak indefinitely.
- Handle async loading/error/data explicitly.
- Prevent duplicate submissions and stale async writes.
- After awaited operations, respect provider lifecycle/mounted state according to the pinned Riverpod API.
- Avoid legacy provider types unless a documented compatibility reason exists.
- Do not add code generation.

## GoRouter conventions

- Construct router once through app composition/provider, not in widget build.
- Keep route registration at the app boundary.
- Centralize route names and path builders; avoid literal route strings scattered across features.
- Validate path/query parameters at the routing boundary.
- Model auth loading, signed-out, and signed-in redirects without loops.
- Use stateful shell navigation only when persistent independent tab stacks are a real product requirement.
- Test deep links, back behavior, route restoration where needed, and malformed parameters.
- Do not use generated route code.

## SOLID, applied pragmatically

- **Single Responsibility:** a module has one coherent reason to change. Avoid classes that mix UI, persistence, parsing, and business rules.
- **Open/Closed:** extend stable behavior through focused composition and explicit variants; do not create plugin frameworks for hypothetical future needs.
- **Liskov Substitution:** implementations honoring a shared contract must preserve its documented behavior and failure semantics. Prefer concrete types until a second real implementation exists.
- **Interface Segregation:** consumers should not depend on broad contracts they do not use. Do not create giant service/repository interfaces.
- **Dependency Inversion:** high-level business rules should not depend directly on vendor SDKs. Inject infrastructure through constructors/providers and keep business calculations pure.

Dart classes are implicitly interfaces. Do not create abstract repository interfaces by default; tests can implement or fake a concrete dependency when appropriate. Add an abstraction for a real seam, second implementation, or independently replaceable boundary.

## Error handling

- Define a small app-level failure vocabulary with safe, user-actionable meaning.
- Translate provider-specific exceptions at the data boundary.
- Preserve diagnostic causes for protected developer logs while excluding secrets and personal nutrition/profile data.
- Distinguish validation, network/offline, authentication, authorization, not-found, conflict, rate-limit, timeout, and unexpected failures where behavior differs.
- Retry only operations that are safe/idempotent; never blindly retry mutations.
- Provide recovery actions and preserve user input on failure where possible.

## Data and nutrition correctness

- Store canonical quantities and units with explicit conversion rules.
- Keep source, serving basis, and confidence/provenance for nutrition values.
- Define rounding only at presentation boundaries unless a domain rule requires otherwise.
- Use decimal-safe or integer-scaled representations where binary floating-point could produce material accumulation errors; document the chosen representation.
- Test serving conversions, per-100g calculations, energy/macronutrient consistency, rounding, date/time boundaries, and locale formatting.
- Never silently treat missing nutrition fields as zero unless the product/data contract explicitly defines that meaning.

## SOLID and code review checklist

Before accepting a change, ask:
- Does each file/class have a clear owner and reason to change?
- Is business logic independent from widgets and external SDKs?
- Is data mapping explicit and validated?
- Is there one source of truth for state/config/tokens/strings?
- Are dependencies directed toward stable contracts?
- Did the change add abstraction without a current consumer or need?
- Are errors, cancellation, retries, and lifecycle behavior deliberate?
- Are tests asserting behavior rather than implementation details?
- Are Arabic/RTL, themes, accessibility, and platform differences covered where relevant?

## Naming and style

- Follow Dart official style and analyzer guidance for the pinned SDK.
- Prefer clear domain names over abbreviations and generic names such as `Manager`, `Helper`, or `Utils`.
- Keep files focused; avoid catch-all folders.
- Make nullability and units explicit in names or types.
- Avoid magic numbers and booleans with unclear meaning.
- Document non-obvious invariants and public contracts, not obvious code.
- Comments explain why, constraints, or risks—not narrate what code already says.
