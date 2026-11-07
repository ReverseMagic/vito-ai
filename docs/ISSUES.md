# Issues and Risks

Track unresolved defects, blockers, and material risks here. Remove resolved entries after adding an appropriate regression test or durable record.

## Open

### RISK-001 — Public repository exposure
- Impact: Source, documentation, and accidental committed configuration are publicly visible.
- Mitigation: Never commit secrets or personal data; enable secret scanning and push protection where available; review dependencies and contributions; use environment-specific secret storage.
- Status: Open; repository owner action may be required to confirm GitHub security settings.

### RISK-002 — Product and service decisions remain open
- Impact: Premature implementation could lock in unsuitable data, privacy, cost, or operational choices.
- Mitigation: Resolve relevant questions in REQUIREMENTS.md and record decisions before implementation.
- Status: Open.

### RISK-003 — No toolchain verification yet
- Impact: Flutter/Dart compatibility, package versions, builds, and runtime behavior have not been verified.
- Mitigation: Pin a verified stable SDK and run the full quality workflow after scaffolding.
- Status: Open.
