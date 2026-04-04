import Foundation

struct MarkdownTab: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let title: String
    let html: String
}

class TabStore: ObservableObject {
    @Published var tabs: [MarkdownTab] = []
    @Published var selectedTabID: UUID?

    static let shared = TabStore()

    var selectedTab: MarkdownTab? {
        tabs.first { $0.id == selectedTabID }
    }

    func openFile(_ url: URL) {
        let validExtensions = ["md", "markdown", "mdown", "mkd", "txt"]
        guard validExtensions.contains(url.pathExtension.lowercased()) else { return }

        // Don't open duplicate tabs
        if let existing = tabs.first(where: { $0.url == url }) {
            selectedTabID = existing.id
            return
        }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            let html = MarkdownParser.toHTML(contents)
            let tab = MarkdownTab(url: url, title: url.lastPathComponent, html: html)
            tabs.append(tab)
            selectedTabID = tab.id
        } catch {
            print("Failed to read file: \(error)")
        }
    }

    func closeTab(_ id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: index)
        if selectedTabID == id {
            if tabs.isEmpty {
                selectedTabID = nil
            } else {
                selectedTabID = tabs[min(index, tabs.count - 1)].id
            }
        }
    }
}
