# Markdown Previewer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS app with a side-by-side markdown editor and live HTML preview.

**Architecture:** Single-window SwiftUI app using HSplitView. Left pane is a TextEditor bound to a @State string. Right pane is a WKWebView wrapped in NSViewRepresentable. Markdown is converted to HTML using a simple parser, with embedded CSS for styling.

**Tech Stack:** Swift, SwiftUI, WebKit (WKWebView), Xcode project via Swift Package Manager

---

### Task 1: Create the Xcode project

**Files:**
- Create: `MarkdownPreviewer/` Xcode project

**Step 1: Generate the Swift package / Xcode project**

Run:
```bash
cd /Users/praveen.sethu/Desktop/workspaces/MarkdownPreviewer
mkdir -p MarkdownPreviewer
```

Create the Xcode project using a `Package.swift` is not ideal for a macOS app. Instead, we'll create the project files manually.

**Step 2: Create the app entry point**

Create `MarkdownPreviewer/MarkdownPreviewerApp.swift`:

```swift
import SwiftUI

@main
struct MarkdownPreviewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1000, height: 600)
    }
}
```

**Step 3: Create a placeholder ContentView**

Create `MarkdownPreviewer/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, Markdown Previewer!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

**Step 4: Create the Xcode project file**

Run:
```bash
# We'll use `swift package init` for structure, then create an Xcode project
# Actually — simplest approach: create a project via xcodebuild or manually.
# For a learning project, we'll create the project structure and use `xcode-select` tooling.
```

Since this is a macOS app (not a CLI tool), we need a proper Xcode project. The simplest way:

Run:
```bash
cd /Users/praveen.sethu/Desktop/workspaces
# Remove the placeholder directory
rm -rf MarkdownPreviewer/MarkdownPreviewer
# We'll create files in the right structure for Xcode
mkdir -p MarkdownPreviewer/MarkdownPreviewer
```

We'll need to create the Xcode `.xcodeproj` using a script or have the user create it via Xcode. The source files go in `MarkdownPreviewer/MarkdownPreviewer/`.

**Step 5: Verify the app builds and launches**

Run: `xcodebuild -project MarkdownPreviewer.xcodeproj -scheme MarkdownPreviewer build`
Expected: BUILD SUCCEEDED, app shows "Hello, Markdown Previewer!"

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: scaffold MarkdownPreviewer macOS app with placeholder ContentView"
```

---

### Task 2: Build the Markdown Parser

**Files:**
- Create: `MarkdownPreviewer/MarkdownPreviewer/MarkdownParser.swift`

**Step 1: Create the markdown-to-HTML converter**

```swift
import Foundation

struct MarkdownParser {
    static func toHTML(_ markdown: String) -> String {
        var html = markdown

        // Headers (h1-h3)
        let headerPatterns: [(String, String)] = [
            ("^### (.+)$", "<h3>$1</h3>"),
            ("^## (.+)$", "<h2>$1</h2>"),
            ("^# (.+)$", "<h1>$1</h1>"),
        ]
        for (pattern, replacement) in headerPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) {
                html = regex.stringByReplacingMatches(
                    in: html,
                    range: NSRange(html.startIndex..., in: html),
                    withTemplate: replacement
                )
            }
        }

        // Bold: **text**
        if let regex = try? NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*") {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<strong>$1</strong>"
            )
        }

        // Italic: *text*
        if let regex = try? NSRegularExpression(pattern: "\\*(.+?)\\*") {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<em>$1</em>"
            )
        }

        // Inline code: `code`
        if let regex = try? NSRegularExpression(pattern: "`(.+?)`") {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<code>$1</code>"
            )
        }

        // Code blocks: ```...```
        if let regex = try? NSRegularExpression(pattern: "```\\w*\\n([\\s\\S]*?)```", options: []) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<pre><code>$1</code></pre>"
            )
        }

        // Unordered lists: - item
        if let regex = try? NSRegularExpression(pattern: "^- (.+)$", options: .anchorsMatchLines) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<li>$1</li>"
            )
        }
        // Wrap consecutive <li> in <ul>
        if let regex = try? NSRegularExpression(pattern: "(<li>.*</li>\\n?)+", options: []) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<ul>$0</ul>"
            )
        }

        // Links: [text](url)
        if let regex = try? NSRegularExpression(pattern: "\\[(.+?)\\]\\((.+?)\\)") {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<a href=\"$2\">$1</a>"
            )
        }

        // Horizontal rule: ---
        if let regex = try? NSRegularExpression(pattern: "^---$", options: .anchorsMatchLines) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<hr>"
            )
        }

        // Paragraphs: wrap remaining plain lines
        let lines = html.components(separatedBy: "\n")
        var result: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                result.append("")
            } else if trimmed.hasPrefix("<") {
                result.append(line)
            } else {
                result.append("<p>\(line)</p>")
            }
        }

        return result.joined(separator: "\n")
    }
}
```

**Step 2: Verify it compiles**

Run: `xcodebuild build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add MarkdownPreviewer/MarkdownPreviewer/MarkdownParser.swift
git commit -m "feat: add MarkdownParser with regex-based markdown-to-HTML conversion"
```

---

### Task 3: Build the WebView wrapper

**Files:**
- Create: `MarkdownPreviewer/MarkdownPreviewer/WebView.swift`

**Step 1: Create the NSViewRepresentable WebView**

```swift
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let fullHTML = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
                padding: 16px 24px;
                line-height: 1.6;
                color: #1d1d1f;
                background-color: #ffffff;
            }
            h1 { font-size: 2em; border-bottom: 1px solid #d1d1d6; padding-bottom: 0.3em; }
            h2 { font-size: 1.5em; border-bottom: 1px solid #d1d1d6; padding-bottom: 0.3em; }
            h3 { font-size: 1.25em; }
            code {
                background-color: #f5f5f7;
                padding: 2px 6px;
                border-radius: 4px;
                font-size: 0.9em;
            }
            pre {
                background-color: #f5f5f7;
                padding: 16px;
                border-radius: 8px;
                overflow-x: auto;
            }
            pre code { background: none; padding: 0; }
            a { color: #0066cc; }
            hr { border: none; border-top: 1px solid #d1d1d6; margin: 24px 0; }
            ul { padding-left: 24px; }
            li { margin: 4px 0; }
            blockquote {
                border-left: 4px solid #d1d1d6;
                margin: 0;
                padding-left: 16px;
                color: #6e6e73;
            }
        </style>
        </head>
        <body>
        \(html)
        </body>
        </html>
        """
        webView.loadHTMLString(fullHTML, baseURL: nil)
    }
}
```

**Step 2: Verify it compiles**

Run: `xcodebuild build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add MarkdownPreviewer/MarkdownPreviewer/WebView.swift
git commit -m "feat: add WebView NSViewRepresentable wrapper with embedded CSS"
```

---

### Task 4: Build the main ContentView with split pane

**Files:**
- Modify: `MarkdownPreviewer/MarkdownPreviewer/ContentView.swift`

**Step 1: Replace placeholder with split-pane layout**

```swift
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

    ```
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
```

**Step 2: Build and run the app**

Run: `xcodebuild build`
Expected: BUILD SUCCEEDED. App shows split pane — editor on left, rendered preview on right.

**Step 3: Commit**

```bash
git add MarkdownPreviewer/MarkdownPreviewer/ContentView.swift
git commit -m "feat: wire up split-pane ContentView with live markdown preview"
```

---

### Task 5: Final polish and verify

**Step 1: Launch the app and test**

- Type in the editor, confirm preview updates live
- Test headers (h1, h2, h3)
- Test bold, italic, inline code
- Test code blocks
- Test lists
- Test links
- Test horizontal rules

**Step 2: Fix any issues found during testing**

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete Markdown Previewer v1 — live side-by-side editor"
```
