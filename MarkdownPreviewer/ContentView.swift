import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = TabStore.shared

    private let defaultHTML = MarkdownParser.toHTML("""
    # Welcome to Markdown Previewer

    Drop `.md` files here or use **File → Open** to get started.

    You can open multiple files — they'll appear as tabs.

    ## Supported Syntax

    - **Bold text** and *italic text*
    - `inline code` and code blocks
    - [Links](https://example.com)
    - Lists, headers, horizontal rules

    > Tip: Right-click any `.md` file in Finder → Open With → MarkdownPreviewer.
    """)

    var body: some View {
        VStack(spacing: 0) {
            if !store.tabs.isEmpty {
                tabBar
            }

            ZStack {
                WebView(html: store.selectedTab?.html ?? defaultHTML)

                DropOverlay { urls in
                    for url in urls {
                        store.openFile(url)
                    }
                }
            }
        }
        .background(Color(nsColor: NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)))
        .onReceive(NotificationCenter.default.publisher(for: .openMarkdownFile)) { notification in
            if let url = notification.object as? URL {
                store.openFile(url)
            } else if let urls = notification.object as? [URL] {
                for url in urls { store.openFile(url) }
            }
        }
    }

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
}
