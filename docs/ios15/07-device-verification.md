# Task 7: Verify on iPhone 7 with iOS 15.8.8

## Goal

Validate the built IPA on the target hardware and document any iOS 15 limitations.

## Prerequisites

- Complete IPA from Task 6.
- iPhone 7 running iOS 15.8.8 with TrollStore installed.
- A paired TwinDesk computer available on the same network or connected by the intended transport.

## Test checklist

1. Install the IPA through TrollStore and launch it.
2. Pair with a computer through the QR URL and reconnect after app relaunch.
3. Confirm discovery, connection, clipboard transfer, file transfer, photos/videos transfer, Remote, media controls, and computer lock.
4. Check Share Extension with a file and a photo from another app.
5. Check Broadcast Extension / screen-sharing entry point.
6. In Shortcuts, add and run each of the seven actions from Task 2.
7. Put the app in the background and verify expected reconnection/background behavior within iOS 15 system limits.
8. Restart the iPhone and confirm the installed app still launches.
9. Record failures with the action, expected result, actual result, device state, and app build number.

## Done when

- All critical connection and transfer flows work on the physical iPhone 7.
- Any unavailable or degraded feature has a documented iOS 15 limitation and a reproducible test result.
- The tested IPA path, version, build number, and test date are recorded in `docs/ios15/device-test-results.md`.

