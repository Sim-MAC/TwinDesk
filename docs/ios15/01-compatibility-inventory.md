# Task 1: Inventory iOS 16 dependencies

## Goal

Produce a complete, source-backed list of APIs that prevent TwinDesk from deploying to iOS 15. Do not make functional changes in this task.

## Current baseline

- `ios/project.yml` declares iOS 16.0 as the deployment target.
- `ios/TwinDesk/Core/Intents.swift` imports `AppIntents`, which is unavailable on iOS 15.
- The SwiftUI app uses iOS 16 navigation APIs and the iOS 16 Photos picker.

## Newly discovered prerequisite tasks

- The iOS 16-only SwiftUI `Layout` protocol (`DeckFlow`), `scrollDisabled`, `scrollContentBackground`, navigation bar toolbar visibility, and sheet detents also need iOS 15 fallbacks.
- App Intents supplies six existing Shortcuts actions. Keep those actions on iOS 16+ and choose an iOS 15 route (for example, SiriKit custom intents) before lowering the deployment target.
- The follow-up order and source locations are recorded in [compatibility-inventory.md](compatibility-inventory.md).

## Work

1. Search `ios/` for availability annotations, `AppIntents`, `PhotosUI`, `PhotosPicker`, `Transferable`, `NavigationStack`, `NavigationSplitView`, `NavigationPath`, `navigationDestination`, and every API marked iOS 16 or newer.
2. Check all three targets: `TwinDesk`, `Share`, and `Broadcast`.
3. For each incompatible API, record:
   - file and symbol;
   - minimum iOS version;
   - feature affected;
   - proposed iOS 15 replacement or fallback;
   - whether it blocks compilation, launch, or only a feature.
4. Add the inventory to `docs/ios15/compatibility-inventory.md`.
5. Update this task file with any newly discovered prerequisite tasks.

## Constraints

- Do not suppress errors with broad availability annotations.
- Do not remove features merely to make compilation succeed.
- Preserve iOS 16+ behavior unless a later task explicitly changes it.

## Done when

- The inventory covers all iOS targets and has no unclassified iOS 16 dependency.
- The next tasks can be implemented from the inventory without another broad search.

