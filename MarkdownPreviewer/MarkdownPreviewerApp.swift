import SwiftUI

@main
struct MarkdownPreviewerApp: App {
    @State private var contentView = ContentViewState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    NotificationCenter.default.post(
                        name: .openMarkdownFile,
                        object: url
                    )
                }
        }
        .defaultSize(width: 1000, height: 600)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open...") {
                    openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }

    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .init(filenameExtension: "md")!,
            .init(filenameExtension: "markdown")!,
            .plainText
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            NotificationCenter.default.post(
                name: .openMarkdownFile,
                object: url
            )
        }
    }
}

class ContentViewState: ObservableObject {}

extension Notification.Name {
    static let openMarkdownFile = Notification.Name("openMarkdownFile")
}
