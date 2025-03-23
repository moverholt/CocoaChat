//
//  MessageContainerView.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/2/25.
//

import Cocoa

class MessageContainerView: NSView {
    let thread: Thread
    
    private var msgViews: [MessageView] = []
    private var spacerHeightConstraint: NSLayoutConstraint!
    private var fontSize: FontSize = .normal
    private let spacerView = NSView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(thread: Thread) {
        self.thread = thread
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        self.layer?.borderColor = NSColor.blue.cgColor
        self.layer?.borderWidth = 2
    }
        
//        self.translatesAutoresizingMaskIntoConstraints = false

//        spacerView.wantsLayer = true
//        spacerView.layer?.borderColor = NSColor.red.cgColor
//        spacerView.layer?.borderWidth = 2
//        spacerView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(spacerView)
//        spacerHeightConstraint = spacerView.heightAnchor.constraint(
//            greaterThanOrEqualToConstant: 0
//        )
//        spacerHeightConstraint.isActive = true
//    }
    

//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//    }
    
//    func clear() {
//        trimMsgViewsAfter(nil)
//    }
//    
//    
//    func addMessage(_ msg: Message, clipHeight: Double, delegate: MessageViewDelegate) {
//        let width = self.frame.width
//        let view = MessageView.create(msg: msg, fontSize: fontSize)
//        view.delegate = delegate
//        view.updateMessage(msg, width: width)
//        
//        self.msgViews.append(view)
//        
//        self.addSubview(view)
//        
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
//        ])
//        
//        refreshVerticalChainLinkConstraints()
//        updateSpacerHeight(clipHeight)
//    }
//    
//    func setFontSize(_ size: FontSize) {
//        fontSize = size
//        for msgView in msgViews {
//            msgView.setFontSize(size)
//            msgView.refreshTextAfterFontSizeChange(width: self.frame.width)
//        }
//        refreshAfterWindowResize()
//    }
//    
//    func updateMessage(_ msg: Message, clipHeight: Double) {
//        let msgView = findView(for: msg)
//        msgView.updateMessage(msg, width: self.frame.width)
//        updateSpacerHeight(clipHeight)
//    }
//    
//    private func updateSpacerHeight(_ clipHeight: Double) {
//        if msgViews.count < 2 {
//            spacerHeightConstraint.constant = 0
//            return
//        }
//        let lastUsrMsg = msgViews[msgViews.count - 2]
//        let lastStrMsg = msgViews[msgViews.count - 1]
//        if lastUsrMsg.role != .user ||
//            lastStrMsg.role != .assistant {
//            spacerHeightConstraint.constant = 0
//            return
//        }
//        
//        let h1 = lastUsrMsg.height
//        let h2 = lastStrMsg.height
//        
//        let newHeight = clipHeight - h1 - h2 - 0
//        if newHeight > 0 {
//            spacerHeightConstraint.constant = newHeight
//        } else {
//            spacerHeightConstraint.constant = 0
//        }
//    }
//    
//    private func findView(for msg: Message) -> MessageView {
//        msgViews.first(where: { $0.id == msg.id })!
//    }
//    
//    func refreshAfterWindowResize() {
//        let width = self.frame.width
//        for msgView in msgViews {
//            msgView.refreshHeightConstraint(width: width)
//        }
//    }
//    
//    func refreshVerticalChainLinkConstraints() {
//        var lastView: MessageView?
//        
//        for cont in msgViews {
//            if let top = cont.superview?.constraints.first(where: { $0.identifier == "top-\(cont.id)" }) {
//                cont.superview?.removeConstraint(top)
//            }
//            
//            if let bottom = cont.superview?.constraints.first(where: { $0.identifier == "bottom-\(cont.id)" }) {
//                cont.superview?.removeConstraint(bottom)
//            }
//            
//            if let last = lastView {
//                let top = cont.topAnchor.constraint(equalTo: last.bottomAnchor, constant: 0)
//                top.identifier = "top-\(cont.id)"
//                top.isActive = true
//            } else {
//                let top = cont.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
//                top.identifier = "top-\(cont.id)"
//                top.isActive = true
//            }
//            
//            lastView = cont
//        }
//        
//        if let view = lastView {
//            
//            let lastViewBtm =
//            view.bottomAnchor.constraint(equalTo: spacerView.topAnchor, constant: 0)
//            lastViewBtm.identifier = "bottom-\(view.id)"
//            lastViewBtm.isActive = true
//            
//            if let spaceBtm = view.superview?.constraints.first(where: { $0.identifier == "spacer-btm" }) {
//                view.superview?.removeConstraint(spaceBtm)
//            }
//            
//            let spacerBtm = spacerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
//            spacerBtm.identifier = "spacer-btm"
//            spacerBtm.isActive = true
//        }
//    }
//    
//    func distanceFromTop(_ msg: Message) -> Double {
//        var h = 0.0
//        for mv in msgViews {
//            if msg.id == mv.id {
//                break
//            }
//            h = h + mv.height
//        }
//        return h
//    }
//    
//    func trimMsgViewsAfter(_ id: Message.ID?) {
//        let index = msgViews.firstIndex(where: { $0.id == id }) ?? 0
//        let removing = Array(msgViews[index...])
//        for view in removing {
//            view.removeFromSuperview()
//        }
//        msgViews = Array(msgViews[..<index])
//        refreshVerticalChainLinkConstraints()
//    }
}
