# iOS 15.8.8 compatibility work

Target: run TwinDesk on an iPhone 7 running iOS 15.8.8 and distribute an unsigned IPA for TrollStore. The app must continue to support newer iOS releases.

Complete these tasks in order. Each task has explicit scope and acceptance criteria. Do not lower the deployment target until the compatibility inventory has been completed: doing so makes the resulting compiler errors harder to classify.

1. [01-compatibility-inventory.md](01-compatibility-inventory.md)
2. [02-legacy-shortcuts.md](02-legacy-shortcuts.md)
3. [03-navigation.md](03-navigation.md)
4. [04-photo-picker.md](04-photo-picker.md)
5. [05-other-ios16-apis.md](05-other-ios16-apis.md)
6. [06-deployment-and-build.md](06-deployment-and-build.md)
7. [07-device-verification.md](07-device-verification.md)

Keep the existing UI and behavior wherever iOS 15 provides an equivalent API. When an iOS 16 feature has no equivalent, provide a graceful iOS 15 fallback and document it in the relevant task's completion notes.

