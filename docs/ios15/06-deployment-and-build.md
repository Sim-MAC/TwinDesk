# Task 6: Set the iOS 15 deployment target and produce an IPA

## Goal

Build an unsigned IPA whose app and embedded extensions declare iOS 15.0 as their minimum deployment target.

## Work

1. Change `ios/project.yml` deployment target from `16.0` to `15.0`.
2. Generate the Xcode project with XcodeGen and check the deployment target for `TwinDesk`, `Share`, and `Broadcast`.
3. Run `ios/build.sh` on macOS with Xcode and XcodeGen.
4. Confirm the resulting archive layout is valid:
   - `ios/dist/TwinDesk.ipa` exists;
   - the IPA contains `Payload/TwinDesk.app`;
   - the app includes its embedded Share and Broadcast extensions;
   - each bundle's `MinimumOSVersion` is 15.0 or lower.
5. Keep `.github/workflows/build-ios.yml` able to build the IPA on demand and upload it as the `TwinDesk-iOS` artifact.
6. Update comments and documentation that claim the app runs only from iOS 16.

## GitHub Actions usage

After this task is merged or pushed to a branch:

1. Open GitHub Actions and select **Build iOS**.
2. Choose **Run workflow**.
3. Enter the branch name in `ref`; leave `tag` empty to receive an artifact only.
4. Download `TwinDesk-iOS` from the completed run's Artifacts section.
5. Extract `TwinDesk.ipa` and install it with TrollStore.

The workflow intentionally creates an unsigned IPA. TrollStore handles installation on the jailbroken device; App Store submission is outside this workflow.

## Done when

- The workflow completes on a macOS runner and uploads `TwinDesk.ipa`.
- IPA metadata confirms iOS 15 compatibility for every embedded bundle.

