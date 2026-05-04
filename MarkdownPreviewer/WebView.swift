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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/vs2015.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
                padding: 12px 20px;
                line-height: 1.5;
                color: #d4d4d4;
                background-color: #1e1e1e;
                margin: 0;
                font-size: 14px;
            }
            h1 { font-size: 1.8em; border-bottom: 1px solid #333; padding-bottom: 0.2em; color: #e6e6e6; margin: 16px 0 8px; }
            h2 { font-size: 1.4em; border-bottom: 1px solid #333; padding-bottom: 0.2em; color: #e6e6e6; margin: 14px 0 6px; }
            h3 { font-size: 1.15em; color: #e6e6e6; margin: 12px 0 4px; }
            code {
                background-color: #2d2d2d;
                padding: 2px 5px;
                border-radius: 3px;
                font-size: 0.9em;
                font-family: "SF Mono", Menlo, "Cascadia Code", Consolas, monospace;
                color: #ce9178;
            }
            pre {
                background-color: #1e1e1e;
                border: 1px solid #333;
                border-radius: 6px;
                padding: 12px;
                overflow-x: auto;
                margin: 8px 0;
            }
            pre code {
                background: none;
                padding: 0;
                color: #d4d4d4;
                font-size: 13px;
                line-height: 1.4;
            }
            a { color: #569cd6; text-decoration: none; }
            a:hover { text-decoration: underline; }
            hr { border: none; border-top: 1px solid #333; margin: 16px 0; }
            ul, ol { padding-left: 20px; margin: 4px 0; }
            li { margin: 2px 0; }
            blockquote {
                border-left: 3px solid #569cd6;
                margin: 8px 0;
                padding-left: 12px;
                color: #808080;
            }
            p { margin: 6px 0; }
            strong { color: #e6e6e6; }
            em { color: #c586c0; }
            .mermaid {
                background-color: #1e1e1e;
                border: 1px solid #333;
                border-radius: 6px;
                padding: 12px;
                margin: 8px 0;
                text-align: center;
                overflow-x: auto;
            }
        </style>
        </head>
        <body>
        \(html)
        <script>
            hljs.highlightAll();
            if (typeof mermaid !== 'undefined') {
                mermaid.initialize({ startOnLoad: false, theme: 'dark', securityLevel: 'loose' });
                mermaid.run({ querySelector: '.mermaid' }).catch(function(e) {
                    console.error('mermaid render failed', e);
                });
            } else {
                document.addEventListener('DOMContentLoaded', function() {
                    if (typeof mermaid !== 'undefined') {
                        mermaid.initialize({ startOnLoad: false, theme: 'dark', securityLevel: 'loose' });
                        mermaid.run({ querySelector: '.mermaid' });
                    }
                });
            }
        </script>
        </body>
        </html>
        """
        // Use an https baseURL so WKWebView allows loading remote scripts
        // (highlight.js + mermaid.js from CDN). With nil baseURL the page has
        // an opaque origin and CDN scripts can be blocked.
        webView.loadHTMLString(fullHTML, baseURL: URL(string: "https://localhost/"))
    }
}
