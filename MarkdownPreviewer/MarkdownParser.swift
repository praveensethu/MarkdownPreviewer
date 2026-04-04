import Foundation

struct MarkdownParser {
    static func toHTML(_ markdown: String) -> String {
        var html = markdown

        // Code blocks first (before other patterns can match inside them)
        if let regex = try? NSRegularExpression(pattern: "```\\w*\\n([\\s\\S]*?)```", options: []) {
            html = regex.stringByReplacingMatches(
                in: html,
                range: NSRange(html.startIndex..., in: html),
                withTemplate: "<pre><code>$1</code></pre>"
            )
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

        return result.joined(separator: "\n")
    }
}
