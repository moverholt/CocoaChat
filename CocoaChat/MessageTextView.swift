//
//  MessageTextView.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/3/25.
//

import Cocoa

class MessageTextView: NSTextView {
    let msg: Thread.Message
    private let padding = 12.0
    private var heightConstraint: NSLayoutConstraint!
    
    convenience init(msg: Thread.Message) {
        let dummy = NSTextView() // FIXME
        self.init(
            frame: dummy.frame,
            textContainer: dummy.textContainer,
            msg: msg
        )
    }
    
    init(frame: NSRect, textContainer: NSTextContainer?, msg: Thread.Message) {
        self.msg = msg
        super.init(frame: frame, textContainer: textContainer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.font = NSFont.systemFont(ofSize: 18)
        
        setupConstraints(width: parentStackView.frame.width)
        if msg.sender == .user {
            self.backgroundColor = NSColor.systemBlue
            self.textColor = NSColor.white
        }
    }
    
    private var parentStackView: NSStackView {
        superview as! NSStackView
    }
    
    private func setupConstraints(width: CGFloat) {
        if heightConstraint == nil {
            translatesAutoresizingMaskIntoConstraints = false
            heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        }
            
        let height = intrinsicSize(of: self, forWidth: width).height + padding
        heightConstraint.constant = height
        heightConstraint.isActive = true
    }
}
