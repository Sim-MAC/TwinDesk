# Task 4: Replace PhotosPicker and Transferable

## Goal

Replace iOS 16 `PhotosPicker` and `Transferable` use with an iOS 15 photo/video picker that preserves multi-item transfer to a computer.

## Known affected areas

- `ios/TwinDesk/UI/HomeView.swift`
- `ios/TwinDesk/UI/FilesView.swift`
- `PickedFile` currently uses `Transferable`.

## Work

1. Build a reusable SwiftUI wrapper around `PHPickerViewController`.
2. Support selecting up to 50 images and videos, matching the current picker behavior.
3. Load every selected item through `NSItemProvider`, copy it into a temporary app-owned URL, and pass that URL to `core.files.adopt(_)`.
4. Keep the Files app importer unchanged unless the inventory identifies an iOS 15 issue.
5. Preserve cancellation and partial-success behavior: a failed item must not discard other selected files.
6. Remove `PhotosPicker`, `PhotosPickerItem`, and `Transferable` dependencies once no longer used.

## Constraints

- Use type identifiers to retain each item's original or appropriate file type and extension.
- Release security-scoped access after copying where applicable.
- Do not load all selected videos into memory.

## Done when

- Overview and Files can each select multiple photos and videos on iOS 15.
- Selected media is sent through the existing file-transfer path.
- The app no longer requires iOS 16 PhotosUI APIs.

