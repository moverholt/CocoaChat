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
   
    private let verticalPadding = 12.0
    private let horizontalPadding = 6.0
    private var heightConstraint: NSLayoutConstraint!
    
    init(text: String, role: ThreadState.Role) {
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
        setupHeightConstraint()
    }
    
    var text: String { textView.string }
    
    private var parentStackView: NSStackView {
        superview as! NSStackView
    }
    
    private func setupHeightConstraint() {
        if heightConstraint == nil {
            heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        }
        let textWidth = parentStackView.frame.width - (horizontalPadding * 2)
        let textHeight = intrinsicSize(of: textView, forWidth: textWidth).height
        heightConstraint.constant = textHeight + (verticalPadding * 2)
        heightConstraint.isActive = true
    }
    
    func setText(_ text: String) {
        textView.string = text
        setupHeightConstraint()
    }
    
    private func setup(_ text: String) {
        textView.drawsBackground = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.string = text
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding)
        ])
    }
}
