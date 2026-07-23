# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MarkdownPreviewer is a lightweight macOS app (SwiftUI + WebKit) that renders `.md` files as a read-only, dark-themed, syntax-highlighted preview with tabbed browsing and drag & drop. There is no in-app editor — the app is preview-only (an earlier design called for a side-by-side editor/preview split view, but that direction was abandoned; `docs/plans/` reflects the original plan and is historical, not current behavior).

## Build & Run

The Xcode project itself is git-ignored and generated from `project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen) — always regenerate after pulling or after changing `project.yml`:

```bash
brew install xcodegen   # one-time
xcodegen generate
xcodebuild -project MarkdownPreviewer.xcodeproj -scheme MarkdownPreviewer -destination 'platform=macOS' build
open ~/Library/Developer/Xcode/DerivedData/MarkdownPreviewer-*/Build/Products/Debug/MarkdownPreviewer.app
```

Or open `MarkdownPreviewer.xcodeproj` in Xcode and press `Cmd+R`.

There is currently no test target/suite in this repo — verification is manual (build + run + click through the app).

## Architecture

The app has a strict one-way data flow with a single piece of shared state:

```
TabStore.shared (ObservableObject, singleton)
  ├── openFile(url) reads file → MarkdownParser.toHTML() → appends MarkdownTab
  └── @Published tabs / selectedTabID drive ContentView's tab bar + preview
```

- **`MarkdownPreviewerApp.swift`** — app entry point. `AppDelegate.application(_:open:)` handles Finder "Open With" / double-click launches; the `Cmd+O` menu command opens an `NSOpenPanel`. Both paths funnel into `TabStore.shared.openFile(url)` — this is the single entry point for loading a file, don't bypass it.
- **`TabModel.swift`** — `TabStore` is a global singleton (`TabStore.shared`), not injected via environment. `MarkdownTab` is an immutable value (`id`, `url`, `title`, pre-rendered `html`) — HTML is computed once at open time, not re-rendered reactively. Opening a URL already present in `tabs` just selects the existing tab instead of duplicating it. Valid extensions (`md`, `markdown`, `mdown`, `mkd`, `txt`) are duplicated as a literal array/set in both `TabStore.openFile` and `DropView.swift` (`hasValidFiles`/`performDragOperation`) — keep them in sync if this list changes.
- **`MarkdownParser.swift`** — a hand-rolled regex-based Markdown → HTML converter (no external Markdown library). Transformation order is significant and load-bearing:
  1. Mermaid fenced blocks (` ```mermaid `) are extracted first and replaced with `<!--MERMAID-i-->` placeholders so later regexes (bold/italic/lists/paragraph-wrapping) can't mangle diagram source.
  2. Remaining fenced code blocks (` ```lang ` ) become `<pre><code class="language-lang">` for highlight.js.
  3. Headers are matched `###` → `##` → `#`, in that order, to avoid `#` prefix-matching a `##`/`###` line.
  4. Inline styles (bold, italic, inline code, links, blockquotes, lists) follow.
  5. Any remaining non-empty, non-tag line gets wrapped in `<p>`.
  6. Mermaid placeholders are re-inserted last as HTML-escaped `<div class="mermaid">` content (escaped because Mermaid reads `textContent`, not `innerHTML`).
  When adding a new Markdown feature, insert the regex at the correct point in this pipeline, not just appended at the end.
- **`WebView.swift`** — `NSViewRepresentable` wrapping `WKWebView`. Every render builds a *complete* HTML document (CSS + `<script>` tags for highlight.js and Mermaid, loaded from CDN — `cdnjs.cloudflare.com` / `cdn.jsdelivr.net`) and calls `loadHTMLString`. It intentionally uses `baseURL: URL(string: "https://localhost/")` rather than `nil` — with a `nil` baseURL the page gets an opaque origin and WKWebView blocks the CDN `<script>` requests. The dark color palette here (VS Code Dark+-inspired) is the single source of truth for preview styling; `MarkdownParser` only emits semantic HTML, no inline styles.
- **`DropView.swift`** — `DropTargetView` is a raw `NSView` (not SwiftUI's `.onDrop`) registered for `.fileURL` drags, overlaid on the preview via `DropOverlay`. `hitTest` returns `nil` so the overlay is invisible to normal clicks/scroll and only intercepts actual drag operations — if you need the overlay to handle more gesture types, you'll need to rethink this hit-testing bypass.

## Conventions worth preserving

- No external Swift package dependencies — Markdown parsing is intentionally hand-rolled rather than pulling in a library; JS libraries (highlight.js, Mermaid) are loaded from CDN inside the rendered HTML, not vendored.
- File-type allow-listing (`md`, `markdown`, `mdown`, `mkd`, `txt`) is enforced at every entry point (open panel content types, drag & drop, `TabStore.openFile`) — new entry points should filter the same way.
- `project.yml` is the source of truth for build settings, bundle ID, and the `CFBundleDocumentTypes`/`UTImportedTypeDeclarations` that register MarkdownPreviewer as a `.md` file handler in Finder. Edit `project.yml`, not a checked-in `.xcodeproj` (it isn't checked in).
