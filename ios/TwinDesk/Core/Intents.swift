// TwinDesk — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
// SiriKit custom intents are handled in the app process so they can safely use Core.shared. An
// Intents extension would have a separate Core instance and could not reuse the live connection.
import Intents

final class TwinDeskIntentHandler: NSObject,
    SendClipboardIntentHandling,
    SaveCopiedFilesIntentHandling,
    ConnectIntentHandling,
    SendFilesIntentHandling,
    ShowScreenIntentHandling,
    PlayPauseIntentHandling,
    LockComputerIntentHandling {

    func handle(intent: SendClipboardIntent, completion: @escaping (SendClipboardIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Send clipboard with ${applicationName}")
        run(.sendClipboard) { result in
            let response = SendClipboardIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    func handle(intent: SaveCopiedFilesIntent, completion: @escaping (SaveCopiedFilesIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Save copied files with ${applicationName}")
        run(.saveCopiedFiles) { result in
            let response = SaveCopiedFilesIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    func handle(intent: ConnectIntent, completion: @escaping (ConnectIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Connect with ${applicationName}")
        run(.connect) { result in
            let response = ConnectIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    func handle(intent: SendFilesIntent, completion: @escaping (SendFilesIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Send files with ${applicationName}")
        run(.sendFiles, files: intent.files ?? []) { result in
            let response = SendFilesIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    func handle(intent: ShowScreenIntent, completion: @escaping (ShowScreenIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Show computer screen with ${applicationName}")
        run(.showScreen) { result in
            let response = ShowScreenIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    func handle(intent: PlayPauseIntent, completion: @escaping (PlayPauseIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Play or pause with ${applicationName}")
        run(.playPause) { result in
            let response = PlayPauseIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    func handle(intent: LockComputerIntent, completion: @escaping (LockComputerIntentResponse) -> Void) {
        intent.suggestedInvocationPhrase = phrase("Lock computer with ${applicationName}")
        run(.lockComputer) { result in
            let response = LockComputerIntentResponse(code: result.succeeded ? .success : .failure, userActivity: nil)
            response.message = result.message
            self.finish(intent, response, successful: result.succeeded, completion: completion)
        }
    }

    private func run(_ action: ShortcutAction, files: [INFile] = [], completion: @escaping (ShortcutOutcome) -> Void) {
        Task { @MainActor in completion(await ShortcutActions.perform(action, files: files)) }
    }

    private func finish<Response: INIntentResponse>(
        _ intent: INIntent,
        _ response: Response,
        successful: Bool,
        completion: (Response) -> Void
    ) {
        if successful { INInteraction(intent: intent, response: response).donate { _ in } }
        completion(response)
    }

    private func phrase(_ key: String) -> String {
        let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "TwinDesk"
        let localized = Bundle.main.localizedString(forKey: key, value: key, table: "AppShortcuts")
        return localized.replacingOccurrences(of: "${applicationName}", with: name)
    }
}
