//
//  NewChatMsgTextView.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/11/25.
//

import Cocoa

protocol NewChatMsgTextViewDelegate {
    func onSubmitNewMsg(_ textField: NewChatMsgTextView)
}

class NewChatMsgTextView: NSTextView {
    var msgDelegate: NewChatMsgTextViewDelegate?

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
            let shiftPressed = event.modifierFlags.contains(.shift)
            if shiftPressed {
                insertNewline(nil)
            } else {
                msgDelegate?.onSubmitNewMsg(self)
            }
        } else {
            super.keyDown(with: event)
        }
    }
}
