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
                font-family: "SF Mono", Menlo, monospace;
            }
            pre {
                background-color: #f5f5f7;
                padding: 16px;
                border-radius: 8px;
                overflow-x: auto;
            }
            pre code { background: none; padding: 0; }
            a { color: #0066cc; text-decoration: none; }
            a:hover { text-decoration: underline; }
            hr { border: none; border-top: 1px solid #d1d1d6; margin: 24px 0; }
            ul { padding-left: 24px; }
            li { margin: 4px 0; }
            blockquote {
                border-left: 4px solid #d1d1d6;
                margin: 0;
                padding-left: 16px;
                color: #6e6e73;
            }
            p { margin: 8px 0; }
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
