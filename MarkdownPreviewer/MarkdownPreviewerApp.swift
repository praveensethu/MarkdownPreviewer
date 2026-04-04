import SwiftUI

@main
struct MarkdownPreviewerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open...") {
                    openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
            }

            CommandGroup(after: .pasteboard) {
                Divider()

                Button("Find...") {
                    NotificationCenter.default.post(name: .toggleSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }

            CommandGroup(after: .importExport) {
                Button("Export as PDF...") {
                    NotificationCenter.default.post(name: .exportPDF, object: nil)
                }
                .keyboardShortcut("p", modifiers: .command)
            }

            CommandMenu("View") {
                Button("Toggle Table of Contents") {
                    NotificationCenter.default.post(name: .toggleTOC, object: nil)
                }
                .keyboardShortcut("t", modifiers: .command)
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
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        if panel.runModal() == .OK {
            for url in panel.urls {
                TabStore.shared.openFile(url)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            TabStore.shared.openFile(url)
        }
    }
}

extension Notification.Name {
    static let openMarkdownFile = Notification.Name("openMarkdownFile")
    static let exportPDF = Notification.Name("exportPDF")
    static let toggleSearch = Notification.Name("toggleSearch")
    static let toggleTOC = Notification.Name("toggleTOC")
}
