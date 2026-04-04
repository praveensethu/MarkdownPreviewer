import SwiftUI

struct ContentView: View {
    @State private var markdown: String = """
    # Welcome to Markdown Previewer

    This is a **live preview** markdown editor built with *SwiftUI*.

    ## Features

    - Type markdown on the left
    - See rendered HTML on the right
    - Updates live as you type

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

    var body: some View {
        HSplitView {
            TextEditor(text: $markdown)
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 300)

            WebView(html: MarkdownParser.toHTML(markdown))
                .frame(minWidth: 300)
        }
    }
}
