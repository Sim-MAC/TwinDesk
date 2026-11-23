// TwinDesk — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

// PHPicker is available on iOS 14 and later and does not require Photos library access.
struct PhotoPicker: UIViewControllerRepresentable {
    let onPicked: ([URL]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .videos])
        configuration.selectionLimit = 50
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPicked: onPicked) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let onPicked: ([URL]) -> Void

        init(onPicked: @escaping ([URL]) -> Void) { self.onPicked = onPicked }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }

            // Load one provider at a time. In particular, videos remain file-backed instead of
            // being materialized as large in-memory Data values.
            loadNext(results, at: 0, urls: [])
        }

        private func loadNext(_ results: [PHPickerResult], at index: Int, urls: [URL]) {
            guard index < results.count else {
                DispatchQueue.main.async { self.onPicked(urls) }
                return
            }

            let provider = results[index].itemProvider
            guard let identifier = provider.registeredTypeIdentifiers.first(where: { id in
                guard let type = UTType(id) else { return false }
                return type.conforms(to: .image) || type.conforms(to: .movie)
            }), let type = UTType(identifier) else {
                loadNext(results, at: index + 1, urls: urls)
                return
            }

            provider.loadFileRepresentation(forTypeIdentifier: identifier) { [self] source, _ in
                var nextURLs = urls
                if let source, let copied = Self.copyFile(from: source, type: type) {
                    nextURLs.append(copied)
                }
                loadNext(results, at: index + 1, urls: nextURLs)
            }
        }

        private static func copyFile(from source: URL, type: UTType) -> URL? {
            do {
                let directory = FileManager.default.temporaryDirectory
                    .appendingPathComponent("TwinDeskPhotos", isDirectory: true)
                    .appendingPathComponent(UUID().uuidString, isDirectory: true)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

                var name = source.lastPathComponent
                if source.pathExtension.isEmpty, let ext = type.preferredFilenameExtension {
                    name += ".\(ext)"
                }
                let destination = directory.appendingPathComponent(name)
                try FileManager.default.copyItem(at: source, to: destination)
                return destination
            } catch {
                // A failed item does not prevent the other selected items from being sent.
                return nil
            }
        }
    }
}
