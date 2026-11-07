# Product Discovery and Technical Research

**Status:** Research baseline — not a final product specification  
**Prepared:** 2026-11-08  
**Scope:** iOS and Android phones; English and Arabic; Flutter; feature-first; manual Riverpod; GoRouter; no code generation.

This document records evidence and product implications. Vendor marketing claims are not treated as independent proof of quality. Competitor features and pricing change; verify them again before making roadmap or commercial decisions.

## 1. Executive findings

1. The category's core workflow is still a daily food diary, but leading products reduce capture friction through multiple input paths: text search, recent/favorite foods, barcode, photo/AI, voice, saved meals, and recipes. Vito should make the diary and fast logging excellent before expanding into peripheral features.
2. Logging is a sequence, not a single button: identify food, choose a trustworthy match, specify serving/quantity, assign meal/date, review nutrition, save, and confirm the diary updated. Every step needs an obvious correction path.
3. AI/photo recognition must be treated as a draft generator, not a nutrition source of truth. YAZIO explicitly describes photo-derived values as rough estimates and allows editing ingredients and portions. Vito should preserve this transparency and user control.
4. Food data quality is a major product risk, especially for Arabic names, Egyptian/MENA prepared dishes, household portions, and local packaged products. A US-centric generic database or a crowdsourced barcode catalog alone is insufficient.
5. Open Food Facts is useful for packaged products but its own documentation warns that user-contributed data may be incomplete or unreliable, and its API has rate limits and search constraints. It cannot be the sole source of nutrition truth or the backing for unrestricted search-as-you-type.
6. USDA FoodData Central provides a strong reference source for many generic foods and branded US products, but requires an API key and its datasets have different provenance and update cadences. Keep keys server-side and preserve data type/source metadata.
7. FAO/INFOODS lists Egypt's national food composition tables from 1996 and regional mixed-dish references from 1984. These are useful research inputs, not proof of current coverage or sufficient stand-alone coverage for today's Egyptian/MENA diet.
8. Competitors differentiate with more insights, meal planning, fasting, activity, community, and premium AI. Vito should not copy feature volume. Its initial differentiation should be reliable local food coverage, low-effort capture, transparent estimates, and polished Arabic-first/English experiences.
9. Motion and microinteractions are part of interaction quality, but every effect must serve feedback or continuity, remain accessible, and pass device profiling.

## 2. Competitor workflow benchmark

The following is a desk-research comparison of publicly documented capabilities. It is not a hands-on teardown of current app builds, and feature availability may vary by subscription, region, language, operating system, or app version.

| Product | Publicly documented strengths | Product lesson for Vito | Caveat / opportunity |
|---|---|---|---|
| MyFitnessPal | Diary-first food logging; search, barcode, meal scan, serving adjustment, saved meals/recipes; free vs paid feature tiers | Keep the diary as the central daily workspace; make serving adjustment and repeat meals fast | Barcode and Meal Scan are subscription-gated; Meal Scan documentation says English-only and has OS/app-version requirements. Do not assume global parity |
| Cronometer | Curated community database, USDA branded data, Nutritionix barcode data, custom foods | Show data provenance and nutrient completeness; distinguish curated foods from user-created entries | Multiple sources have different nutrient coverage and quality; source labels and clear fallbacks matter |
| Lose It! | Search, saved foods, meals, recipes, barcode, photo, and voice logging; daily and weekly progress | Offer multiple capture methods behind one predictable add-food entry point; make repeat logging efficient | Its support documentation says Scan It, Snap It, and Say It are currently English-only—important localization gap |
| YAZIO | Diary with consumed/remaining/burned calories, macros, water, weight, recipes, fasting, AI meal recognition | Keep daily status understandable and put advanced analysis behind progressive disclosure; let users edit AI-detected ingredients and portions | AI estimates are explicitly rough; recipes and AI logging may be paid features; broad feature set risks complexity |
| FatSecret | Food diary, barcode, macros, weight tracking, human-verified database claim, community and achievements | Data curation is a meaningful trust proposition; free core logging can reduce adoption friction | The human-verification claim is vendor-stated; verify methodology and coverage independently. Community/gamification are not automatically suitable for Vito |

### Cross-competitor patterns worth adopting

- A diary or Today screen is the primary daily destination.
- Food capture supports more than one method, but all methods converge on a reviewable food/portion step.
- Recent foods, favorites, meals, and recipes reduce repeated search and typing.
- Food entries expose serving size and quantity, not just a calorie number.
- Daily totals and remaining targets provide immediate feedback after logging.
- Progress history and nutrient detail are useful, but should not overwhelm the primary diary.
- Premium gates commonly apply to advanced capture, insights, and meal planning. This is a commercial pattern, not a decision for Vito.

### Patterns not to copy blindly

- Do not overload the home screen with many cards, streaks, upsells, fasting timers, exercise, community, and charts.
- Do not show AI estimates as exact values or commit them without review.
- Do not assume English-language feature parity means Arabic feature parity.
- Do not use user-contributed data as if it were verified.
- Do not copy competitor subscription boundaries before Vito's value proposition and operating costs are understood.

## 3. Proposed MVP experience (candidate, not yet approved)

### Primary journey

1. Open Today and immediately understand the selected date, logged meals, daily energy target, consumed amount, and remaining amount.
2. Tap one prominent Add food action (also available contextually within a meal).
3. Choose the fastest suitable method: search, recent/favorite, saved meal, barcode, or AI/photo only when its dependencies and quality gates are met.
4. Review the selected food, data source, serving unit, and quantity.
5. Confirm the meal and date; save with immediate feedback.
6. Return to the diary with updated totals and a clear edit/undo path.

### Candidate first-release priorities

**P0 — required foundation**
- App shell, navigation, theme, localization, design tokens, accessibility and motion foundations.
- Onboarding and editable profile/goal setup after calculation rules are agreed.
- Date-aware diary with meal groups and correct totals.
- Food search, food details, serving/quantity selection, add/edit/delete.
- Recent foods and favorites once data ownership is defined.
- Reliable persistence, account/data boundaries, empty/error/offline states.

**P1 — high value if data and platform quality are proven**
- Barcode lookup for packaged foods.
- Custom foods and recipes.
- Weight history and clear trend summaries.
- Regional food catalog expansion and alias/synonym search.

**P2 — only after safety, quality, and economics are demonstrated**
- AI/photo meal parsing, voice capture, coaching, meal planning, integrations, social, subscriptions, push notifications.

This priority order is a recommendation for discovery, not a final scope decision. Validate it with target users and technical feasibility.

## 4. Food data research and implications

### 4.1 USDA FoodData Central

USDA exposes food search and food detail APIs. Its data documentation distinguishes Foundation Foods, FNDDS, Branded Foods, Experimental Foods, and SR Legacy; those types have different collection methods, update frequencies, and meanings. API access requires a data.gov API key, and USDA warns that exposed keys may be deactivated.

**Implications**
- Treat FDC as a source with explicit data type and provenance, not one homogeneous database.
- Keep the API key on a trusted server, never in the Flutter app or public repository.
- Preserve source ID, data type, serving basis, nutrient identifiers/units, and retrieval/version metadata.
- Avoid silently mixing analytically derived generic-food data with label-derived branded data.
- Evaluate its usefulness for common Egyptian foods rather than assuming US coverage transfers.

### 4.2 Open Food Facts

Open Food Facts documents API v3 as current and recommends it for new integrations; v2 remains for backward compatibility, with some search capabilities not available in v3. Its documentation states that data is voluntarily contributed and may not be accurate, complete, or reliable. It lists read-product rate limits and lower search limits, and warns against using its search endpoints for search-as-you-type. The database is ODbL; individual contents and product images have separate licenses.

**Implications**
- Consider it a barcode/product enrichment source, subject to legal/license review and product coverage tests.
- Do not assume product nutrition fields are complete or correct; validate required nutrients and serving basis.
- Do not issue a network request for every keystroke; design debounced, cached, bounded search and evaluate an appropriate search backend if needed.
- Record attribution and share-alike obligations before using or combining datasets. Product image rights differ from database rights.
- Do not bulk mirror or redistribute data until obligations and architecture are reviewed.

### 4.3 Egyptian and regional food composition data

FAO/INFOODS lists Food Composition Tables for Egypt (Nutrition Institute, 1996) and Middle Eastern mixed-dish references including a Gulf States publication from 1984. The age and scope of these resources mean they are research starting points, not proof of current market coverage.

**Implications**
- Build a regional food research set with native Arabic names, common spelling variants, transliterations, regional aliases, preparation methods, and realistic household portions.
- Include Egyptian everyday dishes and variants, not only internationally standardized foods. Examples to investigate include ful medames, ta'ameya, koshari, molokhia, mahshi, rice, baladi bread, feteer, and common home-cooked combinations. These are research targets, not yet validated nutrition records.
- Distinguish raw ingredients, cooked ingredients, recipes, restaurant portions, and packaged products.
- For mixed dishes, document recipe assumptions, ingredient quantities, cooked yield, edible portion, and source of each nutrient value.
- Validate against qualified local nutrition expertise and a documented sampling protocol before claiming coverage or accuracy.

### 4.4 Required food record provenance

Every food record should be able to express, at minimum:
- Source/provider and original source identifier.
- Food type (generic ingredient, prepared dish/recipe, branded packaged product, restaurant item, user-created).
- Name in Arabic and English plus searchable aliases.
- Nutrient basis (per 100 g, per serving, or another explicit basis).
- Serving units, gram weights, edible portion, and conversion source.
- Nutrient values, units, missing-vs-zero distinction, and calculation method.
- Verification status, last reviewed date, and known limitations.
- License/attribution requirements where applicable.

Do not present missing nutrient values as zero. Do not combine incompatible nutrient bases without explicit conversion. Keep user-created foods private by default unless a deliberate sharing model is approved.

## 5. Nutrition calculation and trust requirements

Before implementation, define:
- Canonical units and conversion rules.
- Energy calculation policy and treatment of source-reported energy versus calculated energy.
- Nutrient identifiers, units, precision, and rounding policy.
- Serving and recipe yield calculations.
- How missing, estimated, conflicting, or incomplete data are displayed.
- Date/time-zone boundaries for diary totals.
- Whether and how exercise calories affect targets (not assumed).
- Goal calculation method, safety boundaries, and user override behavior.

Calculations must be deterministic and tested with reviewed fixtures. Keep stored source precision where practical; round for display only. Do not silently change historical diary values when a food catalog record is updated.

## 6. AI capture: guardrails before selection

AI/photo/voice should be an input method that creates an editable draft, not a replacement for food data governance.

Required flow:
1. Capture user input with clear consent and camera/microphone permissions.
2. Parse candidate foods, ingredients, portions, and preparation assumptions.
3. Resolve candidate foods against trusted catalog records where possible.
4. Identify uncertain or ambiguous matches and ask a targeted correction question.
5. Show estimated values with source and uncertainty context.
6. Let the user edit ingredients, quantity, serving, and meal before saving.
7. Save only after explicit user confirmation.

Required controls: schema validation, confidence/uncertainty handling, prompt-injection resistance for model inputs, request size limits, timeout/retry policy, abuse controls, rate limits, per-user cost budgets, privacy/data retention policy, and evaluation against a representative Arabic/English food set. No model or provider is selected in this document.

## 7. UX, motion, and accessibility direction

- One clear primary logging action; avoid multiple competing floating buttons.
- Use progressive disclosure for macro/micronutrient detail.
- Make every AI estimate, serving, and food match editable.
- Use motion to explain state changes, selection, insertion/removal, navigation, and feedback—not to decorate empty space.
- Keep motion tokens centralized; respect Android animation removal and iOS reduced-motion settings.
- Use immediate pressed/selected/loading/success/error feedback. Haptics are supplemental.
- Ensure every gesture has an accessible alternative.
- Validate Arabic RTL and English LTR for navigation, charts, numbers, units, food names, mixed-script labels, keyboard/caret, and transitions.
- Profile motion and scrolling on physical devices; no performance claims without evidence.

## 8. Success metrics to validate in discovery

Do not set arbitrary numerical targets before baseline research. Run moderated usability sessions and establish a baseline, then approve targets with the product owner.

| Metric | Definition | Why it matters |
|---|---|---|
| First-log completion | Percentage of new users who successfully add a first food without help | Tests onboarding-to-value |
| Time to log | Median and 90th percentile time from opening Add Food to confirmed diary entry, by method | Measures friction |
| Logging task success | Percentage of representative food logging tasks completed correctly | Captures usability and data selection quality |
| Correction rate | Percentage of entries edited because of wrong match, portion, or meal | Exposes catalog/AI quality gaps |
| Search success | Percentage of target foods found and correctly selected within an agreed task window | Tests database coverage and search |
| Regional coverage | Recall/precision on a curated Arabic/Egyptian/MENA benchmark set | Tests local relevance |
| Data confidence | Percentage of logged nutrition values with traceable source and valid serving basis | Tests trustworthiness |
| Crash-free sessions and ANR/hang rate | Standard app reliability measures by platform/version | Protects core habit |
| Frame-time/jank | Frame timing during diary scroll, navigation, charts, and motion on representative devices | Tests perceived quality |
| Accessibility task success | Completion of critical tasks with screen readers, large text, and reduced motion | Tests inclusive usability |
| Retention and habit quality | Cohort return and logging consistency, interpreted without shame-based engagement mechanics | Tests sustained usefulness |

## 9. Open decisions — do not infer

- Final name, visual brand, voice, and target audience.
- Initial geography: Egypt-first, GCC-first, or broader MENA.
- Food source mix, data licensing model, and regional data acquisition/validation budget.
- Backend, database, auth, storage, search infrastructure, and data residency.
- AI provider/model, photo/voice support, retention, and cost ceiling.
- Nutrition target methodology and supported goal types.
- Whether barcode, custom foods, recipes, weight tracking, and progress are P0/P1.
- Minimum iOS and Android versions and device support policy.
- Analytics, consent, privacy, export/deletion, and legal review.
- Monetization and feature gating.

## 10. Research sources

Official product documentation and vendor product pages were consulted on 2026-11-08. Competitor feature claims below are vendor-published descriptions, not independent product-quality assessments.

### Competitor sources
- MyFitnessPal — [How to log food](https://support.myfitnesspal.com/hc/en-us/articles/360032274592-How-to-log-food-to-your-diary)
- MyFitnessPal — [Barcode scanner](https://support.myfitnesspal.com/hc/en-us/articles/360032624771-How-to-use-the-Barcode-Scanner)
- MyFitnessPal — [Meal Scan](https://support.myfitnesspal.com/hc/en-us/articles/360045761612-How-to-use-the-Meal-Scanner)
- MyFitnessPal — [Plan feature comparison](https://support.myfitnesspal.com/hc/en-us/articles/34889191368077-The-difference-between-Free-Premium-and-Premium)
- Cronometer — [Data sources](https://support.cronometer.com/hc/en-us/articles/360018239472-Data-Sources)
- Lose It! — [About Lose It!](https://loseit.zendesk.com/hc/en-us/articles/54516668028564-About-Lose-It)
- Lose It! — [How to log food](https://loseit.zendesk.com/hc/en-us/articles/49210381551380-How-to-Log-Food-in-Lose-It)
- YAZIO — [App tutorial](https://help.yazio.com/hc/en-us/articles/11804776635281-Tutorial-of-the-Yazio-app)
- YAZIO — [AI calorie tracking and estimate limitations](https://help.yazio.com/hc/en-us/articles/39137901903889-What-is-the-AI-Calorie-Tracking-Feature-and-how-does-it-work)
- FatSecret — [App features and food database claim](https://www.fatsecret.com/app)

### Food data sources
- USDA — [FoodData Central API Guide](https://fdc.nal.usda.gov/api-guide/)
- USDA — [FoodData Central data documentation](https://fdc.nal.usda.gov/data-documentation/)
- Open Food Facts — [API introduction, version status, limits, and data caveats](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/)
- Open Food Facts — [Licensing guidance](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/tutorials/license-be-on-the-legal-side/)
- FAO/INFOODS — [Egypt food composition tables](https://www.fao.org/infoods/infoods/tables-and-databases/egypt/en/)
- FAO/INFOODS — [Middle East food composition tables](https://www.fao.org/infoods/infoods/tables-and-databases/middle-east/en/)
- FAO — [Food composition tables and databases directory](https://www.fao.org/food-composition/tables-and-databases/en)

### Flutter platform and motion sources
- Flutter — [Internationalizing apps](https://docs.flutter.dev/ui/internationalization)
- Flutter — [Animations overview](https://docs.flutter.dev/ui/animations)
- Flutter — [Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations)
- Flutter API — [MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)
- Flutter — [Performance best practices](https://docs.flutter.dev/perf/best-practices)

## 11. Next discovery tasks

1. Define target users and geography with product-owner input.
2. Create interview and usability task scripts; test existing competitors and paper prototypes.
3. Build an Arabic/English food benchmark (generic foods, mixed dishes, packaged products, household portions) and measure candidate data sources.
4. Complete backend/security/privacy architecture research without selecting a vendor prematurely.
5. Define nutrition calculations and goal methodology with qualified review.
6. Establish baseline performance devices and measurable release budgets.
7. Convert approved outcomes into PRD, user journeys, data model, API contracts, and implementation plan.
