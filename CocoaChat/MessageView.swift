//
//  MessageView.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/3/25.
//

import Cocoa

class MessageView: NSView {
    let role: ThreadState.Role
    private let textView = MessageTextView()
    private let textContainerView: ChatBubbleView
   
    private let topMargin = 12.0
    private let verticalPadding = 12.0
    private let horizontalPadding = 6.0
    private var heightConstraint: NSLayoutConstraint!
    private var textWidthConstraint: NSLayoutConstraint!

    init(text: String, role: ThreadState.Role) {
        self.textContainerView = ChatBubbleView(role: role)
        self.role = role
        super.init(frame: .zero)
        setup(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        textView.font = NSFont.systemFont(ofSize: 18)
        textView.textColor = NSColor.labelColor
        setSizeConstraints()
    }
    
    var text: String { textView.string }
    
    private var parentStackView: NSStackView {
        superview as! NSStackView
    }
    
    private func setSizeConstraints() {
        if heightConstraint == nil {
            heightConstraint = self.heightAnchor.constraint(
                equalToConstant: 0
            )
        }
        if textWidthConstraint == nil {
            textWidthConstraint = textView.widthAnchor.constraint(
                equalToConstant: 0
            )
        }
        
        let stackWidth = parentStackView.frame.width
        let textWidth = stackWidth - (horizontalPadding * 2)
        let size = intrinsicSize(of: textView, maxWidth: textWidth)
        let textHeight = size.height
        
        heightConstraint.constant = textHeight + (verticalPadding * 2) + topMargin
        heightConstraint.isActive = true
        
        textWidthConstraint.constant = size.width
        textWidthConstraint.isActive = true
        textWidthConstraint.priority = NSLayoutConstraint.Priority(
            rawValue: 1000
        )
    }
    
    
    func setText(_ text: String) {
        textView.string = text
        setSizeConstraints()
    }
    
    private func setup(_ text: String) {
        textView.alignment = role == .assistant ? .left : .right
        textView.drawsBackground = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.string = text
        textContainerView.addSubview(textView)

        textContainerView.wantsLayer = true
        textContainerView.layer?.cornerRadius = 18
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textContainerView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(
                equalTo: textContainerView.topAnchor,
                constant: verticalPadding
            ),
            textView.trailingAnchor.constraint(
                equalTo: textContainerView.trailingAnchor,
                constant: -horizontalPadding
            ),
            textView.bottomAnchor.constraint(
                equalTo: textContainerView.bottomAnchor,
                constant: -verticalPadding
            ),
            textView.leadingAnchor.constraint(
                equalTo: textContainerView.leadingAnchor,
                constant: horizontalPadding
            )
        ])
        
        NSLayoutConstraint.activate([
            textContainerView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: topMargin
            ),
            textContainerView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: 0
            ),
        ])
        if role == .user {
            let leading = textContainerView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: 0
            )
            let trailing = textContainerView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: 0
            )
            leading.isActive = true
            trailing.isActive = true
        } else {
            let leading = textContainerView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 0
            )
            let trailing = textContainerView.trailingAnchor.constraint(
                greaterThanOrEqualTo: trailingAnchor,
                constant: 0
            )
            leading.isActive = true
            trailing.isActive = true
        }
    }
    
    class ChatBubbleView: NSView {
        let role: ThreadState.Role
        
        init(role: ThreadState.Role) {
            self.role = role
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            let bubblePath = NSBezierPath()
            let cornerRadius: CGFloat = 12.0
            
            let bubbleRect = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            bubblePath.appendRoundedRect(bubbleRect, xRadius: cornerRadius, yRadius: cornerRadius)
            
            if role == .user {
                NSColor.systemTeal.setFill()
            } else {
                NSColor.controlBackgroundColor.setFill()
            }

            bubblePath.fill()
        }
    }
}
