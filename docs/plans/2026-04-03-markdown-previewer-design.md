# Markdown Previewer — Design Document

## Goal
A simple macOS app for learning Swift/SwiftUI. Side-by-side markdown editor with live HTML preview.

## Architecture
Single-window SwiftUI app with a horizontal split view:
- **Left pane:** TextEditor for markdown input
- **Right pane:** WKWebView rendering HTML preview
- Live update as the user types

## Files

| File | Purpose |
|------|---------|
| `MarkdownPreviewerApp.swift` | App entry point, window configuration |
| `ContentView.swift` | Main split-pane view, holds `@State` markdown string |
| `WebView.swift` | `NSViewRepresentable` wrapper for `WKWebView` |
| `MarkdownParser.swift` | Markdown text → HTML string conversion |

## Data Flow
```
User types → @State markdown updates → markdown converted to HTML → WebView re-renders
```

## Key Decisions
- **No external dependencies** — use Apple's built-in markdown support for beginner-friendliness
- **Embedded CSS** — basic stylesheet in the HTML template for clean preview styling
- **Starter text** — pre-populated sample markdown so app isn't blank on launch
- **Window size** — default ~1000x600, resizable

## Out of Scope
- File open/save
- Syntax highlighting in editor
- Multiple tabs/documents
- Themes or settings
- Export to PDF
