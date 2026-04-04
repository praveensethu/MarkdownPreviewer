import Foundation

struct MarkdownParser {
    static func toHTML(_ markdown: String) -> String {
        var html = markdown

        // Code blocks first — preserve language for highlight.js
        if let regex = try? NSRegularExpression(pattern: "```(\\w*)\\n([\\s\\S]*?)```", options: []) {
            let mutableHTML = NSMutableString(string: html)
            regex.replaceMatches(in: mutableHTML, range: NSRange(location: 0, length: mutableHTML.length), withTemplate: "<pre><code class=\"language-$1\">$2</code></pre>")
            html = mutableHTML as String
        }

        // Headers (h1-h3) — add id attributes for TOC anchors
        let headerLevels: [(String, Int)] = [
            ("^### (.+)$", 3),
            ("^## (.+)$", 2),
            ("^# (.+)$", 1),
        ]
        for (pattern, level) in headerLevels {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) {
                let mutable = NSMutableString(string: html)
                let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
                for match in matches.reversed() {
                    let titleRange = match.range(at: 1)
                    if let range = Range(titleRange, in: html) {
                        let title = String(html[range])
                        let slug = title.lowercased()
                            .replacingOccurrences(of: " ", with: "-")
                            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
                        let replacement = "<h\(level) id=\"\(slug)\">\(title)</h\(level)>"
                        mutable.replaceCharacters(in: match.range, with: replacement)
                    }
                }
                html = mutable as String
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

        return result.joined(separator: "\n")
    }
}
