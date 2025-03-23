//
//  ChatViewController.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Cocoa


class ChatViewController:
    NSViewController,
    NSWindowDelegate,
    NewChatMsgTextViewDelegate,
    NSTextViewDelegate,
    OpenAIStreamingDelegate {
    private let thread: Thread!
    private let streaming: OpenAIStreaming!

    @IBOutlet weak var newMsgTextView: NewChatMsgTextView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var docView: NSView!
    @IBOutlet weak var stackView: NSStackView!
    @IBAction func onSendMsg(_ sender: Any) {
        onClickSend()
    }
    @IBOutlet weak var sendBtn: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var spacer: NSView!
    @IBOutlet weak var spacerHeight: NSLayoutConstraint!
    
    init(thread: Thread, streaming: OpenAIStreaming) {
        self.thread = thread
        self.streaming = streaming
        super.init(
            nibName: NSNib.Name("ChatViewController"),
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.streaming.delegate = self
        setupConstraints()
    }
    
    override func viewDidAppear() {
        print("View did appear")
        
        self.view.window?.delegate = self
        self.newMsgTextView.msgDelegate = self
        self.newMsgTextView.delegate = self
        self.newMsgTextView.string = ""
        self.sendBtn.isEnabled = false
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        syncThreadMsgsToStackView()
    }
    
    override func viewDidLayout() {
        print("View did layout")
        super.viewDidLayout()
        updateSpacerHeight()
    }
    
    var lastUserMsgView: MessageTextView? {
        msgTextViews.filter({ $0.msg.sender == .user }).last
    }
    
    var lastAssistantView: MessageTextView? {
        msgTextViews.filter({ $0.msg.sender == .assistant }).last
    }
    
    func updateSpacerHeight() {
        let ch = scrollView.contentView.bounds.height
        let lum = lastUserMsgView
        let lam = lastAssistantView
        
        var const = ch - (lum?.bounds.height ?? 0)
        if let lam = lam {
            if msgTextViews.firstIndex(of: lam) == msgTextViews.count - 1 {
                const -= lam.bounds.height
            }
        }
        spacerHeight.constant = const
    }
    
    func scrollToLastUserMsg() {
        guard let lum = msgTextViews.last else {
            return
        }
        let coords = lum.convert(lum.bounds, to: stackView)
        let offset = stackView.bounds.maxY - coords.maxY
        scrollToOffset(offset)
    }
    
    func syncThreadMsgsToStackView() {
        if msgTextViews.count == thread.messages.count { return }
        let newMsgs = thread.messages.dropFirst(msgTextViews.count)
        newMsgs.forEach { msg in
            let tv = MessageTextView(msg: msg)
            tv.string = msg.text
            stackView.addArrangedSubview(tv)
        }
    }
    
    private func setupConstraints() {
        let clipView = scrollView.contentView
        docView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            docView.topAnchor.constraint(equalTo: clipView.topAnchor),
            docView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
            docView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
        ])
    }
    
    var msgTextViews: [MessageTextView] {
        stackView.arrangedSubviews.compactMap { v in
            v as? MessageTextView
        }
    }
    
    func windowDidResize(_ notification: Notification) {
    }
    
    func onSubmitNewMsg(_ textField: NewChatMsgTextView) {
        handleSubmit()
    }
    
    func handleSubmit() {
        let text = newMsgTextView.string.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if text.isEmpty {
            return
        }
        thread.addUserMessage(text)
        streaming.streamThread(thread, model: "gpt-4o")
        newMsgTextView.string = ""
        sendBtn.title = "Stop"
        spinner.startAnimation(nil)
        syncThreadMsgsToStackView()
        scrollToLastUserMsg()
        updateSpacerHeight()
    }
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else {
            return
        }
        sendBtn.isEnabled = !textView.string.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }
    
    private func scrollToOffset(_ yOffset: CGFloat) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            scrollView.contentView.animator().setBoundsOrigin(
                NSPoint(x: 0, y: yOffset)
            )
        } completionHandler: {
            self.scrollView.reflectScrolledClipView(
                self.scrollView.contentView
            )
        }
    }
    
    func streamDone(_ text: String) {
        Task { @MainActor in
            spinner.stopAnimation(nil)
            sendBtn.title = "Send"
            thread.endStreamingMsg(text)
            updateSpacerHeight()
        }
    }
    
    private var stackMsgTextViews: [MessageTextView] {
        stackView.arrangedSubviews.compactMap { v in
            v as? MessageTextView
        }
    }
    
    func streamUpdate(_ body: String) {
        Task { @MainActor in
            if thread.streaming {
                thread.updateStreamingMsg(body)
                stackMsgTextViews.last?.string = body
            } else {
                thread.startStreamingMsg(body)
                syncThreadMsgsToStackView()
            }
            updateSpacerHeight()
        }
    }
    
    private func cancelStreaming() {
        streaming.stopListening()
        thread.endStreamingMsg("")
        spinner.stopAnimation(nil)
        sendBtn.title = "Send"
    }
        
    
    private func onClickSend() {
        if streaming.active {
            cancelStreaming()
        } else {
            handleSubmit()
        }
    }
}
