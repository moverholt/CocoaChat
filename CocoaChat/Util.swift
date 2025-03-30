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

func intrinsicSize(of textView: NSTextView, maxWidth: CGFloat) -> NSSize {
    guard let textContainer = textView.textContainer,
          let layoutManager = textView.layoutManager else {
        return .zero
    }
    
    let originalWidthTracks = textContainer.widthTracksTextView
    
    textContainer.widthTracksTextView = false
    textContainer.containerSize = NSSize(
        width: CGFloat.greatestFiniteMagnitude,
        height: .greatestFiniteMagnitude
    )
    layoutManager.ensureLayout(for: textContainer)
    let naturalRect = layoutManager.usedRect(for: textContainer)
    
    if naturalRect.width <= maxWidth {
        textContainer.widthTracksTextView = originalWidthTracks
        return NSSize(
            width: ceil(naturalRect.width),
            height: ceil(naturalRect.height)
        )
    }
    
    textContainer.containerSize = NSSize(
        width: maxWidth,
        height: .greatestFiniteMagnitude
    )
    layoutManager.ensureLayout(for: textContainer)
    let constrainedRect = layoutManager.usedRect(for: textContainer)
    
    textContainer.widthTracksTextView = originalWidthTracks
    return NSSize(width: maxWidth, height: ceil(constrainedRect.height))
}


func generateWindowTitle(_ thread: ThreadState) async -> String {
    let prompt = "Generate a window title from the first prompt above. Do not put quotes around your response."
    var msgs = thread.messages.map({
        OpenAI.Message(
            role: $0.sender == .user ? "user" : "assistant",
            content: $0.text
        )
    })
    msgs.append(OpenAI.Message(role: "user", content: prompt))
    let resp = await OpenAI.shared.chatCompletion(
        messages: msgs, model: "gpt-4o"
    )
        
    switch resp {
    case let .success(completion):
        return completion.choices[0].message.content
    case .failure:
        return "Window Title"
    }
}
