import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var markdown: String = """
    # Welcome to Markdown Previewer

    This is a **live preview** markdown editor built with *SwiftUI*.

    ## Features

    - Type markdown on the left
    - See rendered HTML on the right
    - Updates live as you type
    - Drag & drop `.md` files to open them

    ## Code Example

    Here's some inline `code` and a code block:

    ```swift
    let greeting = "Hello, world!"
    print(greeting)
    ```

    ---

    ### Links

    Check out [Apple's SwiftUI docs](https://developer.apple.com/swiftui/) for more.

    > This is a blockquote. It adds visual emphasis to quoted text.
    """

    @State private var currentFileURL: URL?
    @State private var isDropTargeted = false

    var body: some View {
        HSplitView {
            TextEditor(text: $markdown)
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 300)

            WebView(html: MarkdownParser.toHTML(markdown))
                .frame(minWidth: 300)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isDropTargeted ? Color.accentColor : Color.clear, lineWidth: 3)
                .padding(4)
        )
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url = url else { return }
                loadFile(from: url)
            }
            return true
        }
        .onReceive(NotificationCenter.default.publisher(for: .openMarkdownFile)) { notification in
            if let url = notification.object as? URL {
                loadFile(from: url)
            }
        }
    }

    func loadFile(from url: URL) {
        let validExtensions = ["md", "markdown", "mdown", "mkd", "txt"]
        guard validExtensions.contains(url.pathExtension.lowercased()) else { return }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            DispatchQueue.main.async {
                self.markdown = contents
                self.currentFileURL = url
            }
        } catch {
            print("Failed to read file: \(error)")
        }
    }
}
