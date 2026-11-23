# Task 5: Resolve remaining iOS 16 API dependencies

## Goal

Resolve every remaining incompatibility from the Task 1 inventory after Shortcuts, navigation, and photo selection have been migrated.

## Work

1. Handle each remaining item individually. Likely examples include SwiftUI modifiers such as `scrollContentBackground`, presentation APIs, or platform-specific UIKit/WebKit APIs.
2. For APIs with an iOS 15 equivalent, use that equivalent.
3. For cosmetic APIs without an equivalent, guard their use with `if #available(iOS 16, *)` and retain a readable iOS 15 appearance.
4. Ensure all iOS 16+ code paths are availability-guarded from an iOS 15 deployment target.
5. Update `docs/ios15/compatibility-inventory.md` to mark each item resolved, with its chosen fallback.

## Constraints

- Do not use deployment-target conditionals to exclude functional source files from iOS 15.
- Preserve behavior of Share and Broadcast extensions.
- Keep all permissions and background behavior valid on iOS 15.

## Done when

- There are no unresolved entries in the compatibility inventory.
- A clean iOS 15-targeted build reports no availability errors.

