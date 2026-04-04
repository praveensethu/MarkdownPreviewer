import Foundation

struct TOCEntry: Identifiable, Hashable {
    let id = UUID()
    let level: Int
    let title: String
    let anchor: String
}

struct MarkdownTab: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let title: String
    let html: String
    let markdown: String
    let headers: [TOCEntry]
    let wordCount: Int
    let readingTime: String
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

        if let existing = tabs.first(where: { $0.url == url }) {
            selectedTabID = existing.id
            return
        }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            let html = MarkdownParser.toHTML(contents)
            let headers = parseHeaders(from: contents)
            let words = countWords(in: contents)
            let time = readingTime(wordCount: words)
            let tab = MarkdownTab(url: url, title: url.lastPathComponent, html: html,
                                  markdown: contents, headers: headers,
                                  wordCount: words, readingTime: time)
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

    private func parseHeaders(from markdown: String) -> [TOCEntry] {
        var entries: [TOCEntry] = []
        for line in markdown.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("### ") {
                let title = String(trimmed.dropFirst(4))
                entries.append(TOCEntry(level: 3, title: title, anchor: slugify(title)))
            } else if trimmed.hasPrefix("## ") {
                let title = String(trimmed.dropFirst(3))
                entries.append(TOCEntry(level: 2, title: title, anchor: slugify(title)))
            } else if trimmed.hasPrefix("# ") {
                let title = String(trimmed.dropFirst(2))
                entries.append(TOCEntry(level: 1, title: title, anchor: slugify(title)))
            }
        }
        return entries
    }

    private func slugify(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }

    private func countWords(in text: String) -> Int {
        let cleaned = text.replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "-", with: "")
        let words = cleaned.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
        return words.count
    }

    private func readingTime(wordCount: Int) -> String {
        let minutes = max(1, Int(ceil(Double(wordCount) / 200.0)))
        return "\(minutes) min read"
    }
}
