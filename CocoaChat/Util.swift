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


func intrinsicSize(of textView: NSTextView, forWidth width: CGFloat) -> NSSize {
    textView.textContainer?.containerSize = NSSize(
        width: width,
        height: .greatestFiniteMagnitude
    )
    textView.textContainer?.widthTracksTextView = true
    
    guard let layoutManager = textView.layoutManager,
          let textContainer = textView.textContainer else {
        return .zero
    }
    
    layoutManager.ensureLayout(for: textContainer)
    let usedRect = layoutManager.usedRect(for: textContainer)
    
    return NSSize(width: width, height: usedRect.height)
}
