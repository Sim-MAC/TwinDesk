# Task 2: Replace AppIntents with iOS 15-compatible Shortcuts

## Goal

Replace the `AppIntents.framework` implementation with an iOS 15-compatible Shortcuts integration while retaining all feasible actions.

## Existing implementation

`ios/TwinDesk/Core/Intents.swift` currently exposes these actions through `AppIntent` and `AppShortcutsProvider`:

1. Send Clipboard to Computer
2. Save Files Copied on Computer
3. Connect to Computer
4. Send Files to Computer
5. Show Computer Screen
6. Play or Pause on Computer
7. Lock Computer

## Work

1. Add an iOS 15 compatible Intent Extension using the legacy `Intents` framework and custom intent definitions, where that is the appropriate legacy API.
2. Define and implement all seven actions, including the file input needed by **Send Files to Computer**.
3. Move shared action logic out of `AppIntent.perform()` methods into app-owned code that both the extension and app can invoke safely.
4. Preserve the existing connection wait and user-visible results where the legacy API supports them.
5. Configure the extension target, Info.plist, generated intent classes, signing-disabled build settings, and embedding in `ios/project.yml`.
6. Remove `import AppIntents`, `AppIntent`, `AppShortcut`, and `AppShortcutsProvider` use from production sources.
7. Update localized Intent titles, descriptions, and Siri phrases. Retire only resources that are specific to App Intents and are no longer consumed.

## Implementation decision

SiriKit supports handling intents in the app process on iOS 14 and later through `UIApplicationDelegate.application(_:handlerFor:)`. TwinDesk uses that route for all seven actions instead of an Intents extension: each action depends on `Core.shared` and some also read the app's clipboard or update its UI, so an extension would need an IPC/session bridge and could not safely reuse the live app state. The app declares its supported intent classes in `INIntentsSupported`. An extension would be appropriate only if the actions were moved onto a standalone service that can operate independently of the app process.

## Important implementation questions

- A legacy Intent Extension executes out of process. Do not assume `Core.shared` in the extension is the already-running app's session.
- Decide for each action whether it needs to launch the app via an app URL / user activity, or can complete safely in the extension.
- File URLs supplied by Shortcuts may be security-scoped or temporary. Copy files into a safe temporary directory before handing them to the app.
- Verify that custom intents appear in the iOS 15 Shortcuts app and can be added to automations where iOS permits it.

## Done when

- The app has no AppIntents framework dependency.
- All seven actions are visible and invocable from Shortcuts on iOS 15, or any platform limitation is explicitly documented with the closest working alternative.
- Existing iOS 16+ Shortcuts behavior remains functional.

