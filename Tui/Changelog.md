# Tui Changelog

## 0.1.0-P1 — Foundation & Profiles

### Added
- New `TUI` namespace and modular core foundation.
- New profile storage model: profiles own their live configuration instead of snapshotting the whole SavedVariables tree.
- Per-character, per-specialization profile assignments.
- Custom preset registry.
- Safe profile/preset import-export format (`TUI1:`) with no `loadstring` execution.
- Import preview metadata and per-module selection support.
- Profile-aware desired states for optional Tui addons.
- Central `DisplayGuard` and `DisplayQueue` foundation for installer / What's New / modal safety.
- First Azure Dark options shell.

### Next
- Full mover/layout engine.
- Installer flow and preset previews.
- Role/spec/content overlays.
- Complete UnitFrames/ResourceBars rebuild.
