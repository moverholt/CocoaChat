//
//  Util.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/9/25.
//

import AppKit

class FlippedClipView: NSClipView {
    override var isFlipped: Bool {
        true
    }
}

//func intrinsicSize(of textView: NSTextView, forWidth width: CGFloat) -> NSSize {
//    textView.textContainer?.containerSize = NSSize(
//        width: width,
//        height: .greatestFiniteMagnitude
//    )
//    textView.textContainer?.widthTracksTextView = true
//    
//    guard let layoutManager = textView.layoutManager,
//          let textContainer = textView.textContainer else {
//        return .zero
//    }
//    
//    layoutManager.ensureLayout(for: textContainer)
//    let usedRect = layoutManager.usedRect(for: textContainer)
//    
//    return NSSize(width: width, height: usedRect.height)
//}

//func intrinsicSize(of textView: NSTextView, maxWidth: CGFloat) -> NSSize {
//    guard let textContainer = textView.textContainer,
//          let layoutManager = textView.layoutManager else {
//        return .zero
//    }
//    
//    let originalWidthTracks = textContainer.widthTracksTextView
//    
//    textContainer.widthTracksTextView = false
//    textContainer.containerSize = NSSize(
//        width: CGFloat.greatestFiniteMagnitude,
//        height: .greatestFiniteMagnitude
//    )
//    layoutManager.ensureLayout(for: textContainer)
//    let naturalRect = layoutManager.usedRect(for: textContainer)
//    
//    if naturalRect.width <= maxWidth {
//        textContainer.widthTracksTextView = originalWidthTracks
//        return NSSize(
//            width: ceil(naturalRect.width),
//            height: ceil(naturalRect.height)
//        )
//    }
//    
//    textContainer.containerSize = NSSize(
//        width: maxWidth,
//        height: .greatestFiniteMagnitude
//    )
//    layoutManager.ensureLayout(for: textContainer)
//    let constrainedRect = layoutManager.usedRect(for: textContainer)
//    
//    textContainer.widthTracksTextView = originalWidthTracks
//    return NSSize(width: maxWidth, height: ceil(constrainedRect.height))
//}

    /// Returns the smallest `NSSize` an `NSTextView` needs, capping its width at `maxWidth`.
    /// If the string fits on one line inside `maxWidth`, the height is just one line;
    /// otherwise the text is laid out with wrapping and the resulting height is returned.
//func intrinsicSize(of textView: NSTextView, maxWidth: CGFloat) -> NSSize {
//    
//        // ----- 1.  Single‑line measurement -----
//        // Using boundingRect **without** `.usesLineFragmentOrigin` keeps everything on one line.
//    let attr = textView.textStorage ?? NSAttributedString()
//    let oneLine = attr.boundingRect(
//        with: CGSize(width: CGFloat.greatestFiniteMagnitude,
//                     height: .greatestFiniteMagnitude),
//        options: [.usesFontLeading, .usesDeviceMetrics],   // no wrapping
//        context: nil
//    ).integral.size        // integral == ceil on both axes
//    
//        // If the single line is narrow enough, we’re done.
//    if oneLine.width <= maxWidth {
//        return oneLine
//    }
//    
//        // ----- 2.  Wrapped measurement -----
//    guard let textContainer = textView.textContainer,
//          let layoutManager = textView.layoutManager else {
//            // Fallback when the text view is in an incomplete state.
//        let wrapped = attr.boundingRect(
//            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            context: nil
//        ).integral.size
//        return NSSize(width: maxWidth, height: wrapped.height)
//    }
//    
//        // Preserve the container’s original state so we can restore it later.
//    let originalTracksWidth = textContainer.widthTracksTextView
//    let originalSize        = textContainer.containerSize
//    
//    textContainer.widthTracksTextView = false
//    textContainer.containerSize       = NSSize(width: maxWidth,
//                                               height: .greatestFiniteMagnitude)
//    
//    layoutManager.ensureLayout(for: textContainer)
//    let wrappedRect = layoutManager.usedRect(for: textContainer).integral
//    
//        // Restore everything we changed.
//    textContainer.containerSize       = originalSize
//    textContainer.widthTracksTextView = originalTracksWidth
//    
//    return NSSize(width: maxWidth, height: wrappedRect.height)
//}


func generateWindowTitle(_ thread: ThreadState) async -> String {
    let prompt = "Generate a window title from the first prompt above. Do not put quotes around your response."
    var msgs = thread.messages.map({
        OpenAI.Message(
            role: $0.sender == .user ? "user" : "assistant",
            content: $0.text
        )
    })
    msgs.append(OpenAI.Message(role: "user", content: prompt))
    let resp = await OpenAI.shared.chatCompletion(messages: msgs, model: "gpt-4o")
        
    switch resp {
    case let .success(completion):
        return completion.choices[0].message.content
    case .failure:
        return "Window Title"
    }
}

func intrinsicSize(of textView: NSTextView, maxWidth: CGFloat) -> NSSize {
    textView.layoutManager?.ensureLayout(for: textView.textContainer!)
    let container = NSTextContainer(containerSize: NSSize(width: maxWidth, height: .greatestFiniteMagnitude))
    container.lineFragmentPadding = textView.textContainer?.lineFragmentPadding ?? 0
    let layoutManager = NSLayoutManager()
    layoutManager.addTextContainer(container)
    let textStorage = NSTextStorage(attributedString: textView.attributedString())
    textStorage.addLayoutManager(layoutManager)
    layoutManager.glyphRange(for: container)
    let usedRect = layoutManager.usedRect(for: container)
    return NSSize(width: ceil(usedRect.width), height: ceil(usedRect.height))
}


extension String {
    var fourCharCodeValue: Int {
        var result: Int = 0
        if let data = self.data(using: String.Encoding.macOSRoman),
           data.count == 4 {
            data.withUnsafeBytes { rawBufferPointer in
                if let rawPtr = rawBufferPointer.baseAddress {
                    result = rawPtr.load(as: Int.self)
                }
            }
        }
        return result
    }
}
