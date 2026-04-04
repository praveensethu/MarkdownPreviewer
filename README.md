# MarkdownPreviewer

A lightweight macOS markdown previewer with a dark theme, VS Code-style syntax highlighting, tabbed browsing, and drag & drop support.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Dark theme** — VS Code Dark+ inspired color scheme
- **Syntax highlighting** — powered by highlight.js with the vs2015 theme
- **Tabs** — open multiple markdown files side by side
- **Drag & drop** — drop `.md` files onto the window to preview them
- **File association** — right-click any `.md` file in Finder → Open With → MarkdownPreviewer
- **Cmd+O** — open files via the native file picker
- **Markdown support** — headers, bold, italic, code blocks, inline code, links, lists, blockquotes, horizontal rules

## Screenshot

```
┌──────────────────────────────────────────────┐
│ README.md  ×  │  CHANGELOG.md  ×  │          │
├──────────────────────────────────────────────┤
│                                              │
│  # My Project                                │
│                                              │
│  A **bold** statement with *italic* flair.   │
│                                              │
│  ```swift                                    │
│  let greeting = "Hello, world!"              │
│  print(greeting)                             │
│  ```                                         │
│                                              │
└──────────────────────────────────────────────┘
```

## Getting Started

### Requirements

- macOS 13.0+
- Xcode 15+ (to build from source)
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Build & Run

```bash
git clone https://github.com/praveensethu/MarkdownPreviewer.git
cd MarkdownPreviewer
xcodegen generate
xcodebuild -project MarkdownPreviewer.xcodeproj -scheme MarkdownPreviewer -destination 'platform=macOS' build
open ~/Library/Developer/Xcode/DerivedData/MarkdownPreviewer-*/Build/Products/Debug/MarkdownPreviewer.app
```

Or open `MarkdownPreviewer.xcodeproj` in Xcode and press `Cmd+R`.

### Pre-built App

Download `MarkdownPreviewer.zip` from the releases page, unzip, and double-click to run. On first launch, right-click → **Open** to bypass Gatekeeper.

## Project Structure

```
MarkdownPreviewer/
├── MarkdownPreviewerApp.swift   # App entry point, menu commands, file open handler
├── ContentView.swift            # Main view with tab bar and preview area
├── WebView.swift                # WKWebView wrapper with dark CSS + highlight.js
├── MarkdownParser.swift         # Regex-based markdown → HTML converter
├── TabModel.swift               # Tab state management
├── DropView.swift               # Native NSView drag & drop handler
└── Assets.xcassets/             # App icon (M↓ on dark gradient)
```

## Tech Stack

- **SwiftUI** — UI framework
- **WebKit** — HTML rendering via WKWebView
- **highlight.js** — syntax highlighting for code blocks
- **xcodegen** — Xcode project generation

## License

MIT
