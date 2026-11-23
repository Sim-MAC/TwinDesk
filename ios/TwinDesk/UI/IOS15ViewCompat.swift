// TwinDesk — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
import SwiftUI
import UIKit

enum CompatibleSheetSize: Equatable {
    case medium
    case large
}

struct CompatibleSheet: ViewModifier {
    let size: CompatibleSheetSize

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents(size == .medium ? [.medium] : [.large])
        } else {
            content.background(SheetSizeConfigurator(size: size).frame(width: 0, height: 0))
        }
    }
}

private struct SheetSizeConfigurator: UIViewControllerRepresentable {
    let size: CompatibleSheetSize

    func makeUIViewController(context: Context) -> Controller { Controller(size: size) }
    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.size = size
        controller.configure()
    }

    final class Controller: UIViewController {
        var size: CompatibleSheetSize
        init(size: CompatibleSheetSize) { self.size = size; super.init(nibName: nil, bundle: nil) }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            configure()
        }

        func configure() {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                var ancestor: UIViewController? = self
                while let current = ancestor {
                    if let sheet = current.sheetPresentationController {
                        switch self.size {
                        case .medium:
                            sheet.detents = [.medium(), .large()]
                            sheet.selectedDetentIdentifier = .medium
                            sheet.prefersGrabberVisible = true
                        case .large:
                            sheet.detents = [.large()]
                            sheet.selectedDetentIdentifier = .large
                            sheet.prefersGrabberVisible = false
                        }
                        return
                    }
                    ancestor = current.parent
                }
            }
        }
    }
}

struct CompatibleListBackground: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content.background(ListBackgroundConfigurator().frame(width: 0, height: 0))
        }
    }
}

private struct ListBackgroundConfigurator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) { controller.clearListBackground() }

    final class Controller: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            clearListBackground()
        }

        func clearListBackground() {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                var root: UIViewController = self
                while let parent = root.parent { root = parent }
                if let view = root.view { Self.clearTableBackgrounds(in: view) }
            }
        }

        private static func clearTableBackgrounds(in view: UIView) {
            if let table = view as? UITableView {
                table.backgroundColor = .clear
                table.backgroundView = UIView(frame: .zero)
            }
            for child in view.subviews { clearTableBackgrounds(in: child) }
        }
    }
}

struct CompatibleScrollEnabled: ViewModifier {
    let enabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDisabled(!enabled)
        } else {
            content.background(ScrollEnabledConfigurator(enabled: enabled).frame(width: 0, height: 0))
        }
    }
}

struct PersistentOverlaysCompat: ViewModifier {
    let hidden: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.persistentSystemOverlays(hidden ? .hidden : .automatic)
        } else {
            content
        }
    }
}

struct TapLocationCompat: ViewModifier {
    let action: (CGPoint) -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.onTapGesture(count: 1, coordinateSpace: .local, perform: action)
        } else if #available(iOS 16.0, *) {
            content.simultaneousGesture(SpatialTapGesture(coordinateSpace: .local).onEnded { action($0.location) })
        } else {
            content.simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { value in
                    guard abs(value.translation.width) < 8, abs(value.translation.height) < 8 else { return }
                    action(value.startLocation)
                }
            )
        }
    }
}

struct MultilineTextInput: View {
    let title: String
    @Binding var text: String

    var body: some View {
        if #available(iOS 16.0, *) {
            TextField(title, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
        } else {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(title).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text).padding(.horizontal, 4).padding(.vertical, 2)
            }
            .frame(minHeight: 76, maxHeight: 140)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.25)))
        }
    }
}

private struct ScrollEnabledConfigurator: UIViewControllerRepresentable {
    let enabled: Bool

    func makeUIViewController(context: Context) -> Controller { Controller(enabled: enabled) }
    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.enabled = enabled
        controller.updateScrollView()
    }

    final class Controller: UIViewController {
        var enabled: Bool
        init(enabled: Bool) { self.enabled = enabled; super.init(nibName: nil, bundle: nil) }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateScrollView()
        }

        func updateScrollView() {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard var root = self.view else { return }
                while let parent = root.superview { root = parent }
                Self.setHorizontalScrolls(in: root, enabled: self.enabled)
            }
        }

        private static func setHorizontalScrolls(in view: UIView, enabled: Bool) {
            if let scroll = view as? UIScrollView,
               scroll.alwaysBounceHorizontal ||
                (scroll.contentSize.width > scroll.bounds.width + 1 && scroll.contentSize.height <= scroll.bounds.height + 1) {
                scroll.isScrollEnabled = enabled
            }
            for child in view.subviews { setHorizontalScrolls(in: child, enabled: enabled) }
        }
    }
}
