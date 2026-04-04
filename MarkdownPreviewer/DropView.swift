import SwiftUI
import AppKit

struct DropOverlay: NSViewRepresentable {
    var onDrop: ([URL]) -> Void

    func makeNSView(context: Context) -> DropTargetView {
        let view = DropTargetView()
        view.onDrop = onDrop
        return view
    }

    func updateNSView(_ nsView: DropTargetView, context: Context) {
        nsView.onDrop = onDrop
    }
}

class DropTargetView: NSView {
    var onDrop: (([URL]) -> Void)?
    private var isDragging = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Only handle drag events — pass all other events (scroll, click) through
        return nil
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return false
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard hasValidFiles(sender) else { return [] }
        isDragging = true
        needsDisplay = true
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragging = false
        needsDisplay = true
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return hasValidFiles(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDragging = false
        needsDisplay = true

        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ]) as? [URL] else { return false }

        let validExtensions = Set(["md", "markdown", "mdown", "mkd", "txt"])
        let validURLs = urls.filter { validExtensions.contains($0.pathExtension.lowercased()) }

        if !validURLs.isEmpty {
            onDrop?(validURLs)
            return true
        }
        return false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isDragging {
            NSColor(calibratedRed: 0.2, green: 0.4, blue: 1.0, alpha: 0.15).setFill()
            let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 4), xRadius: 8, yRadius: 8)
            path.fill()
            NSColor(calibratedRed: 0.3, green: 0.5, blue: 1.0, alpha: 0.8).setStroke()
            path.lineWidth = 3
            path.stroke()
        }
    }

    private func hasValidFiles(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ]) as? [URL] else { return false }

        let validExtensions = Set(["md", "markdown", "mdown", "mkd", "txt"])
        return urls.contains { validExtensions.contains($0.pathExtension.lowercased()) }
    }
}
