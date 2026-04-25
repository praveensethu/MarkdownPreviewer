import Foundation

struct MarkdownParser {
    static func toHTML(_ markdown: String) -> String {
        var html = markdown

        // Pull Mermaid blocks out first so their raw content survives all later
        // transformations — re-inserted at the end as <div class="mermaid">.
        var mermaidBlocks: [String] = []
        if let regex = try? NSRegularExpression(pattern: "```mermaid\\n([\\s\\S]*?)```", options: []) {
            let nsHTML = html as NSString
            let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsHTML.length))
            for match in matches {
                mermaidBlocks.append(nsHTML.substring(with: match.range(at: 1)))
            }
            let mutable = NSMutableString(string: html)
            for (i, match) in matches.enumerated().reversed() {
                mutable.replaceCharacters(in: match.range, with: "<!--MERMAID-\(i)-->")
            }
            html = mutable as String
        }

        // Code blocks — preserve language for highlight.js
        if let regex = try? NSRegularExpression(pattern: "```(\\w*)\\n([\\s\\S]*?)```", options: []) {
            let mutableHTML = NSMutableString(string: html)
            regex.replaceMatches(in: mutableHTML, range: NSRange(location: 0, length: mutableHTML.length), withTemplate: "<pre><code class=\"language-$1\">$2</code></pre>")
            html = mutableHTML as String
        }

        // Headers (h1-h3) — order matters, match ### before ##
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

        // Horizontal rule: ---
        if let regex = try? NSRegularExpression(pattern: "^---$", options: .anchorsMatchLines) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<hr>"
            )
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
        if let regex = try? NSRegularExpression(pattern: "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)") {
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

        // Links: [text](url)
        if let regex = try? NSRegularExpression(pattern: "\\[(.+?)\\]\\((.+?)\\)") {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<a href=\"$2\">$1</a>"
            )
        }

        // Blockquotes: > text
        if let regex = try? NSRegularExpression(pattern: "^> (.+)$", options: .anchorsMatchLines) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<blockquote><p>$1</p></blockquote>"
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
        if let regex = try? NSRegularExpression(pattern: "(<li>.+?</li>\\n?)+", options: []) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<ul>$0</ul>"
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

        var finalHTML = result.joined(separator: "\n")

        // Re-insert Mermaid blocks. Escape so the browser preserves chars like
        // <br/> as text — Mermaid reads textContent, not innerHTML.
        for (i, content) in mermaidBlocks.enumerated() {
            let escaped = content
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            finalHTML = finalHTML.replacingOccurrences(
                of: "<!--MERMAID-\(i)-->",
                with: "<div class=\"mermaid\">\n\(escaped)\n</div>"
            )
        }

        return finalHTML
    }
}
