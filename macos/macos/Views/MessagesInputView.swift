import SwiftUI

struct MessagesInputView: View {
    @Binding var text: String
    @State private var textEditorHeight: CGFloat = 40
    var onSubmit: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                // Auto-sizing TextEditor
                ZStack(alignment: .leading) {
                    // TextEditor for message input
                    ResizableTextView(text: $text, onSend: handleSend)
                        .font(.callout)
                        .frame(height: min(textEditorHeight, 100)) // Limit the max height
                        .padding(8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .onChange(of: text) { _ in
                            adjustTextEditorHeight()
                        }
                        .overlay(
                            VStack {
                                if (text.isEmpty) {
                                    Text("Type a message...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding([.top, .leading], 8)
                                }
                            },
                        alignment: .topLeading)
                        .overlay(
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 8),
                        alignment: .bottomTrailing)
                }
            }
            .padding()
        }
    }
    
    private func adjustTextEditorHeight() {
        let maxHeight: CGFloat = 100 // Maximum height for the TextEditor
        let newHeight = text.height(withConstrainedWidth: 400, font: .systemFont(ofSize: 17))
        textEditorHeight = min(newHeight + 20, maxHeight)
    }
    
    private func handleSend() {
        onSubmit() // Call onSubmit closure when sending
        text = ""  // Clear the text
        textEditorHeight = 40 // Reset text editor height
    }
}

struct ResizableTextView: NSViewRepresentable {
    @Binding var text: String
    var onSend: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.backgroundColor = NSColor.controlBackgroundColor
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != text {
            nsView.string = text
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: ResizableTextView

        init(_ parent: ResizableTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if NSEvent.modifierFlags.contains(.shift) {
                    // Shift + Enter for newline
                    textView.insertNewlineIgnoringFieldEditor(self)
                } else {
                    // Enter for send
                    parent.onSend()
                    return true
                }
            }
            return false
        }
    }
}

#Preview {
    MessagesInputView(text: .constant(""), onSubmit: {})
}
