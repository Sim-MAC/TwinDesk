# Task 3: Replace iOS 16 SwiftUI navigation

## Goal

Make the app's phone and iPad navigation compile and work on iOS 15.

## Known affected areas

- `ios/TwinDesk/UI/RootView.swift` uses `NavigationStack`, `NavigationSplitView`, navigation paths, and `navigationDestination`.
- `DeckView.swift` and `SearchView.swift` also use `NavigationStack`.

## Work

1. Use the inventory from Task 1 to identify every navigation API unavailable on iOS 15.
2. Introduce a navigation compatibility layer or rewrite the affected views using `NavigationView` and `NavigationLink` as appropriate.
3. Preserve these behaviors:
   - bottom tabs and the More page;
   - opening a page programmatically through `AppUI`;
   - returning a reselected tab to its root;
   - search navigation;
   - modal covers for the viewer, Remote, and Deck;
   - iPad sidebar/detail navigation.
4. Use runtime availability branching only where retaining the modern implementation meaningfully reduces risk. Both branches must be compile checked.

## Constraints

- Do not make iOS 15 navigation state depend on an unavailable `NavigationPath` type.
- Avoid duplicating page content or connection state across navigation branches.
- Do not change deep-link behavior for `twindesk://` pairing links.

## Done when

- The app compiles with an iOS 15 deployment target.
- A user can reach every existing page on iPhone and iPad layouts.
- Programmatic navigation and Back behavior work without crashes on iOS 15.

