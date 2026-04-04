import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = TabStore.shared
    @State private var showTOC = false
    @State private var showSearch = false
    @State private var searchQuery = ""
    let webViewCoordinator = WebViewCoordinator()

    private let defaultMarkdown = """
    # Welcome to Markdown Previewer

    Drop `.md` files here or use **File → Open** to get started.

    You can open multiple files — they'll appear as tabs.

    ## Supported Syntax

    - **Bold text** and *italic text*
    - `inline code` and code blocks
    - [Links](https://example.com)
    - Lists, headers, horizontal rules

    ## Keyboard Shortcuts

    - **Cmd+O** — Open file
    - **Cmd+P** — Export as PDF
    - **Cmd+F** — Find in document
    - **Cmd+T** — Toggle table of contents

    > Tip: Right-click any `.md` file in Finder → Open With → MarkdownPreviewer.
    """

    private var currentHTML: String {
        store.selectedTab?.html ?? MarkdownParser.toHTML(defaultMarkdown)
    }

    private var currentHeaders: [TOCEntry] {
        store.selectedTab?.headers ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            if !store.tabs.isEmpty {
                tabBar
            }

            if showSearch {
                searchBar
            }

            HSplitView {
                if showTOC && !currentHeaders.isEmpty {
                    tocSidebar
                }

                ZStack {
                    WebView(html: currentHTML, coordinator: webViewCoordinator)

                    DropOverlay { urls in
                        for url in urls {
                            store.openFile(url)
                        }
                    }
                }
            }

            statusBar
        }
        .background(Color(nsColor: NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)))
        .onReceive(NotificationCenter.default.publisher(for: .openMarkdownFile)) { notification in
            if let url = notification.object as? URL {
                store.openFile(url)
            } else if let urls = notification.object as? [URL] {
                for url in urls { store.openFile(url) }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportPDF)) { _ in
            webViewCoordinator.exportPDF()
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleSearch)) { _ in
            showSearch.toggle()
            if !showSearch { searchQuery = "" }
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleTOC)) { _ in
            showTOC.toggle()
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(store.tabs) { tab in
                    tabButton(for: tab)
                }
            }
        }
        .background(Color(nsColor: NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)))
    }

    private func tabButton(for tab: MarkdownTab) -> some View {
        let isSelected = store.selectedTabID == tab.id

        return HStack(spacing: 6) {
            Text(tab.title)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .white : .gray)
                .lineLimit(1)

            Button(action: { store.closeTab(tab.id) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
            .opacity(isSelected ? 1 : 0.5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected
            ? Color(nsColor: NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1))
            : Color.clear)
        .overlay(
            Rectangle()
                .frame(height: isSelected ? 2 : 0)
                .foregroundColor(.blue),
            alignment: .top
        )
        .contentShape(Rectangle())
        .onTapGesture {
            store.selectedTabID = tab.id
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 12))

            TextField("Find in document...", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .onSubmit {
                    webViewCoordinator.findText(searchQuery)
                }

            if !searchQuery.isEmpty {
                Button(action: { webViewCoordinator.findText(searchQuery) }) {
                    Text("Next")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)

                Button(action: {
                    searchQuery = ""
                    webViewCoordinator.findText("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: NSColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)))
    }

    // MARK: - Table of Contents Sidebar

    private var tocSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("TABLE OF CONTENTS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
                    .tracking(0.5)
                Spacer()
                Button(action: { showTOC = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(currentHeaders) { entry in
                        Button(action: {
                            webViewCoordinator.webView?.evaluateJavaScript(
                                "document.getElementById('\(entry.anchor)')?.scrollIntoView({behavior:'smooth'})"
                            )
                        }) {
                            Text(entry.title)
                                .font(.system(size: 12))
                                .foregroundColor(entry.level == 1 ? .white : .gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, CGFloat((entry.level - 1) * 12))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 12)
                    }
                }
            }
        }
        .frame(minWidth: 180, maxWidth: 220)
        .background(Color(nsColor: NSColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)))
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack {
            if let tab = store.selectedTab {
                Text("\(tab.wordCount) words")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)

                Text("·")
                    .foregroundColor(Color(nsColor: NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)))

                Text(tab.readingTime)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            if showTOC {
                Text("TOC")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(3)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: NSColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)))
    }
}
