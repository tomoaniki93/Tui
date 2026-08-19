# Tui 0.1.0-P1 — Foundation Profiles

This package is the first clean Tui foundation. It is intentionally not a TomoMod rename.

## Test now
1. Copy all `Tui*` folders into `World of Warcraft/_retail_/Interface/AddOns/`.
2. Enable `Tui`, `Tui_Libs`, `Tui_Options` and any optional Tui module stubs you want to test.
3. Log in and run `/tui`.
4. Test Profiles, Modules, Presets, spec assignment and `/reload` persistence.

## Profile design
A profile owns:
- `theme`
- `layout`
- desired `modules`
- per-component configuration under `components[componentID]`

This avoids copying the whole root SavedVariables tree on every profile switch.

## Import / Export
The engine is already implemented in `Tui/Core/Profiles/ImportExport.lua`.
- Full profile export/import.
- Custom preset export/import.
- Import preview metadata.
- Per-section selection.
- Per-component selection.
- Per-module selection and desired activation state.
- Safe custom serializer; no `loadstring`.
- Uses LibDeflate automatically if it is later provided by `Tui_Libs`; otherwise uses Base64 fallback.

The GUI for the import wizard is intentionally scheduled for the next GUI pass; the engine is ready first.

## Display safety
`DisplayGuard` + `DisplayQueue` are already in the core. Installer / What's New must request display through this system instead of calling `:Show()` on login.

## Next pass
- Mover/Layout framework.
- Installer UI.
- Role/spec/content preset overlays and visual preview.
- Import/export GUI wizard.
- Start UnitFrames + ResourceBars shared engine.
