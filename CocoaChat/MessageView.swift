//
//  MessageView.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/3/25.
//

import Cocoa

protocol MessageViewDelegate {
    func onEditBtnClick(_ msgId: UUID)
}

typealias MsgId = UUID

class MessageView: NSView {
    let role: ThreadState.Role
    let id: MsgId
    var delegate: MessageViewDelegate?
    
    private let textView = MessageTextView()
    private let textContainerView: ChatBubbleView
    private var trackingArea: NSTrackingArea?
    private var editBtn: NSButton!
   
    private let topMargin = 12.0
    private let verticalPadding = 12.0
    private let horizontalPadding = 6.0
    private var heightConstraint: NSLayoutConstraint!
    private var textWidthConstraint: NSLayoutConstraint!

    init(
        _ id: MsgId,
        text: String,
        role: ThreadState.Role,
        fontSize: FontSize
    ) {
        self.textContainerView = ChatBubbleView(role: role)
        self.role = role
        self.id = id
        super.init(frame: .zero)
        initialize(with: text, fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func layout() {
        super.layout()
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
                lessThanOrEqualToConstant: 0
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
    }
    
    func setText(_ text: String) {
        textView.string = text
        self.needsLayout = true
        self.layoutSubtreeIfNeeded()
    }
    
    private func initialize(with text: String, fontSize: FontSize) {
        textView.font = NSFont.systemFont(ofSize: fontSize.value)
        textView.textColor = NSColor.labelColor
        textView.alignment = role == .assistant ? .left : .right
        textView.drawsBackground = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.string = text
        textContainerView.addSubview(textView)
        
//        textView.wantsLayer = true
//        textView.layer?.borderColor = NSColor.red.cgColor
//        textView.layer?.borderWidth = 1
//        
//        textContainerView.wantsLayer = true
//        textContainerView.layer?.borderColor = NSColor.blue.cgColor
//        textContainerView.layer?.borderWidth = 1
//        
//        self.wantsLayer = true
//        self.layer?.borderColor = NSColor.green.cgColor
//        self.layer?.borderWidth = 2

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
                lessThanOrEqualTo: trailingAnchor,
                constant: 0
            )
            leading.isActive = true
            trailing.isActive = true
        }
        
        editBtn = NSButton(
            title: "Edit",
            target: self,
            action: #selector(onEditBtnClick(_:))
        )
        editBtn.translatesAutoresizingMaskIntoConstraints = false
        editBtn.isHidden = true
        addSubview(editBtn)

        NSLayoutConstraint.activate([
            editBtn.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 12
            ),
            editBtn.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 12
            )
        ])
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
    
    func setFontSize(_ fontSize: FontSize) {
        textView.font = NSFont.systemFont(ofSize: fontSize.value)
        self.needsLayout = true
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let existingTrackingArea = trackingArea {
            self.removeTrackingArea(existingTrackingArea)
        }
        
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInKeyWindow
        ]
        
        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = trackingArea {
            self.addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if role == .user {
            editBtn.isHidden = false
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        if role == .user {
            editBtn.isHidden = true
        }
    }
    
    @objc func onEditBtnClick(_ sender: NSButton) {
        print("Edit button was clicked!")
        delegate?.onEditBtnClick(id)
    }
}
