// TwinDesk — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
// The app-side work shared by the legacy SiriKit handlers. Keep Core access here, never in an
// Intents extension process: Core owns this app's live connection and session state.
import Foundation
import Intents

enum ShortcutAction {
    case sendClipboard, saveCopiedFiles, connect, sendFiles, showScreen, playPause, lockComputer
}

struct ShortcutOutcome {
    let succeeded: Bool
    let message: String
}

@MainActor
enum ShortcutActions {
    static func perform(_ action: ShortcutAction, files: [INFile] = []) async -> ShortcutOutcome {
        let core = Core.shared
        switch action {
        case .connect:
            core.start()
            guard let id = core.store.lastHostId ?? core.store.hosts().first?.id,
                  let host = core.store.host(id) else {
                return fail("Pair a computer in TwinDesk first.")
            }
            core.connect(host)
            return done(tr("Connecting to {name}…", ["name": host.name]))

        case .sendClipboard:
            guard await ready(core) else { return fail("Not connected to a computer.") }
            return core.clip.sendCurrent(force: true)
                ? done(tr("Sent to {name}.", ["name": core.link.host?.name ?? tr("the computer")]))
                : fail("Nothing to send.")

        case .saveCopiedFiles:
            guard core.connected, core.fclip.offer != nil else { return fail("Nothing copied on the computer.") }
            core.fclip.save()
            return done("Saving to Files › TwinDesk.")

        case .sendFiles:
            guard await ready(core) else { return fail("Not connected to a computer.") }
            let urls = copyFiles(files)
            guard !urls.isEmpty, core.files.send(urls) else { return fail("Nothing to send.") }
            let name = core.link.host?.name ?? tr("the computer")
            let itemLabel = urls.count == 1 ? urls[0].lastPathComponent : trCount(urls.count, "file")
            return done(tr("Sending {items} to {name}.", ["items": itemLabel, "name": name]))

        case .showScreen:
            guard await ready(core) else { return fail("Not connected to a computer.") }
            AppUI.shared.cover = .viewer
            return done("Showing the computer’s screen.")

        case .playPause:
            guard await ready(core) else { return fail("Not connected to a computer.") }
            core.media.ctl("toggle")
            return done("Done.")

        case .lockComputer:
            guard await ready(core) else { return fail("Not connected to a computer.") }
            core.dev.act("lock")
            return done(tr("Locking {name}.", ["name": core.link.host?.name ?? tr("the computer")]))
        }
    }

    private static func ready(_ core: Core) async -> Bool {
        core.wake()
        for _ in 0..<30 where !core.connected { try? await Task.sleep(nanoseconds: 100_000_000) }
        return core.connected
    }

    private static func copyFiles(_ files: [INFile]) -> [URL] {
        guard !files.isEmpty else { return [] }
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("shortcut-" + UUID().uuidString, isDirectory: true)
        do { try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true) }
        catch { return [] }

        var copied: [URL] = []
        var usedNames = Set<String>()
        for (index, file) in files.enumerated() {
            guard let source = file.fileURL else { continue }
            let accessed = source.startAccessingSecurityScopedResource()
            defer { if accessed { source.stopAccessingSecurityScopedResource() } }
            let proposedName = file.filename.isEmpty ? source.lastPathComponent : file.filename
            let safeName = URL(fileURLWithPath: proposedName).lastPathComponent
            let base = (safeName as NSString).deletingPathExtension
            let ext = (safeName as NSString).pathExtension
            var filename = safeName.isEmpty ? "File \(index + 1)" : safeName
            var suffix = 2
            while !usedNames.insert(filename).inserted {
                filename = ext.isEmpty ? "\(base) \(suffix)" : "\(base) \(suffix).\(ext)"
                suffix += 1
            }
            let destination = directory.appendingPathComponent(filename.isEmpty ? "File \(index + 1)" : filename)
            guard (try? FileManager.default.copyItem(at: source, to: destination)) != nil else { continue }
            copied.append(destination)
        }
        return copied
    }

    private static func done(_ message: String) -> ShortcutOutcome { ShortcutOutcome(succeeded: true, message: message) }
    private static func fail(_ message: String) -> ShortcutOutcome { ShortcutOutcome(succeeded: false, message: tr(message)) }
}
