import SwiftUI
import WebKit

class WebViewCoordinator: NSObject {
    var webView: WKWebView?

    func exportPDF() {
        guard let webView = webView else { return }
        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = false

        let printOp = webView.printOperation(with: printInfo)
        printOp.showsPrintPanel = true
        printOp.showsProgressPanel = true
        printOp.run()
    }

    func findText(_ query: String) {
        guard let webView = webView else { return }
        if query.isEmpty {
            webView.evaluateJavaScript("window.getSelection().removeAllRanges()")
        } else {
            let escaped = query.replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")
            webView.evaluateJavaScript("""
                window.find('\(escaped)', false, false, true, false, true, false);
            """)
        }
    }
}

struct WebView: NSViewRepresentable {
    let html: String
    var coordinator: WebViewCoordinator?

    func makeCoordinator() -> WebViewCoordinator {
        return coordinator ?? WebViewCoordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.webView = webView
        let fullHTML = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/vs2015.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
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
            @media print {
                body { background-color: white; color: #1d1d1f; }
                h1, h2, h3, strong { color: #1d1d1f; }
                h1, h2 { border-bottom-color: #ccc; }
                code { background-color: #f0f0f0; color: #c7254e; }
                pre { background-color: #f5f5f5; border-color: #ccc; }
                pre code { color: #333; }
                a { color: #0066cc; }
                blockquote { border-left-color: #0066cc; color: #555; }
                em { color: #333; }
            }
        </style>
        </head>
        <body>
        \(html)
        <script>hljs.highlightAll();</script>
        </body>
        </html>
        """
        webView.loadHTMLString(fullHTML, baseURL: nil)
    }
}
