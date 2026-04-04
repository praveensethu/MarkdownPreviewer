import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var html: String = ""
    @State private var currentFileURL: URL?
    @State private var isDropTargeted = false

    private let defaultMarkdown = """
    # Welcome to Markdown Previewer

    Drop a `.md` file here or use **File → Open** to get started.

    ## Supported Syntax

    - **Bold text** and *italic text*
    - `inline code` and code blocks
    - [Links](https://example.com)
    - Lists, headers, horizontal rules

    > Tip: You can also right-click any `.md` file in Finder and choose "Open With" → MarkdownPreviewer.
    """

    var body: some View {
        ZStack {
            WebView(html: html)

            if isDropTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 4)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)
                    .padding(8)
            }
        }
        .onAppear {
            html = MarkdownParser.toHTML(defaultMarkdown)
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onReceive(NotificationCenter.default.publisher(for: .openMarkdownFile)) { notification in
            if let url = notification.object as? URL {
                loadFile(from: url)
            }
        }
        .navigationTitle(currentFileURL?.lastPathComponent ?? "Markdown Previewer")
    }

    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            DispatchQueue.main.async {
                loadFile(from: url)
            }
        }
    }

    private func loadFile(from url: URL) {
        let validExtensions = ["md", "markdown", "mdown", "mkd", "txt"]
        guard validExtensions.contains(url.pathExtension.lowercased()) else { return }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            DispatchQueue.main.async {
                self.html = MarkdownParser.toHTML(contents)
                self.currentFileURL = url
            }
        } catch {
            print("Failed to read file: \(error)")
        }
    }
}
