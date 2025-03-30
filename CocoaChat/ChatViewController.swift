//
//  ChatViewController.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Cocoa

class ChatViewController:
    NSViewController,
    NewChatMsgTextViewDelegate,
    NSTextViewDelegate,
    OpenAIStreamingDelegate {
    private let streaming: OpenAIStreaming!
    private let initalThreadState: ThreadState?
    private(set) var streamingMsgView: MessageView?

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
    @IBOutlet weak var modelsPopUpBtn: NSPopUpButton!
    @IBAction func onSelectModelsPopUp(_ sender: Any) {
        let modelId = modelsPopUpBtn.title
        UserSettings.shared.setDefaultModelId(modelId)
    }
    @IBOutlet weak var statusView: NSView!
    @IBOutlet weak var statusButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBAction func onClickStatusBtn(_ sender: Any) {
        Task {
            await connectAndSetup()
        }
    }
    
    init(thread: ThreadState?, streaming: OpenAIStreaming) {
        self.streaming = streaming
        self.initalThreadState = thread
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
        
        newMsgTextView.string = ""
        newMsgTextView.msgDelegate = self
        newMsgTextView.delegate = self
        
        streaming.delegate = self
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
        
        Task {
            await connectAndSetup()
        }
    }
    
    private func connectAndSetup() async {
        statusLabel.stringValue = "Connecting to OpenAI..."
        statusLabel.textColor = .systemBlue
        statusButton.isHidden = true
        modelsPopUpBtn.isHidden = true
        newMsgTextView.isEditable = false
        sendBtn.isEnabled = false

        let resp = await OpenAI.shared.models()
        switch resp {
        case let .success(models):
            setupModelOptions(models)
            statusLabel.stringValue = "Connected"
            modelsPopUpBtn.isHidden = false
            newMsgTextView.isEditable = true
            setupControllerWithThreadState(initalThreadState)
        case let .failure(err):
            statusLabel.stringValue = err.localizedDescription
            statusLabel.textColor = .red
            statusButton.isHidden = false
        }
    }
    
    override func viewDidAppear() {
        print("View did appear")
        chatWindowController.window?.title = initalThreadState?.title ?? "New Chat Window"
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        updateSpacerHeight()
    }
    
    var lastUserMsgView: MessageView? {
        stackMsgViews.filter({ $0.role == .user }).last
    }
    
    var lastAssistantView: MessageView? {
        stackMsgViews.filter({ $0.role == .assistant }).last
    }
    
    var stackMsgViews: [MessageView] {
        stackView.arrangedSubviews.compactMap { v in v as? MessageView }
    }
    
    var modelId: String { modelsPopUpBtn.title }
    
    var threadState: ThreadState { ThreadState(self) }
    
    var chatWindowController: ChatWindowController {
        view.window!.windowController as! ChatWindowController
    }
    
    private func updateSpacerHeight() {
        let ch = scrollView.contentView.bounds.height
        let lum = lastUserMsgView
        let lam = lastAssistantView
        
        var const = ch - (lum?.bounds.height ?? 0)
        if let lam = lam {
            if stackMsgViews.firstIndex(of: lam) == stackMsgViews.count - 1 {
                const -= lam.bounds.height
            }
        }
        spacerHeight.constant = const
    }
    
    private func scrollToLastUserMsg() {
        guard let lum = stackMsgViews.last else { return }
        let coords = lum.convert(lum.bounds, to: stackView)
        let offset = stackView.bounds.maxY - coords.maxY
        scrollToOffset(offset)
    }
    
    private func setupControllerWithThreadState(_ thread: ThreadState?) {
        guard let thread = thread else { return }
        thread.messages.forEach { msg in
            let tv = MessageView(text: msg.text, role: msg.sender)
            stackView.addArrangedSubview(tv)
        }
        if let sm = thread.streamingMsg {
            streamingMsgView = addAssistantMsgViewToStackView(sm.text)
        }
        modelsPopUpBtn.selectItem(withTitle: thread.modelId)
        updateStatusView()
    }
    
    private func setupConstraints() {
        let clipView = scrollView.contentView
        docView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            docView.topAnchor.constraint(equalTo: clipView.topAnchor),
            docView.leadingAnchor.constraint(
                equalTo: clipView.leadingAnchor
            ),
            docView.trailingAnchor.constraint(
                equalTo: clipView.trailingAnchor
            ),
        ])
    }
    
    func onSubmitNewMsg(_ textField: NewChatMsgTextView) {
        handleSubmit()
    }
    
    private func handleSubmit() {
        let text = newMsgTextView.string.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if text.isEmpty { return }
        newMsgTextView.string = ""
        sendBtn.title = "Stop"
        spinner.startAnimation(nil)
        addUserMsgViewToStackView(text)
        let ts = threadState
        if ts.messages.count == 1 {
            Task {
                let title = await generateWindowTitle(ts)
                chatWindowController.window?.title = title
            }
        }
        streaming.streamThread(ts, model: modelId)
        scrollToLastUserMsg()
        updateSpacerHeight()
        updateStatusView()
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
            streamingMsgView = nil
            updateSpacerHeight()
        }
    }

    func streamUpdate(_ body: String) {
        Task { @MainActor in
            if let smv = streamingMsgView {
                smv.setText(body)
            } else {
                streamingMsgView = addAssistantMsgViewToStackView(body)
            }
            updateSpacerHeight()
        }
    }
    
    private func cancelStreaming() {
        streaming.stopListening()
        spinner.stopAnimation(nil)
        sendBtn.title = "Send"
        streamingMsgView = nil
    }
        
    
    private func onClickSend() {
        if streaming.active {
            cancelStreaming()
        } else {
            handleSubmit()
        }
    }
    
    private func addUserMsgViewToStackView(_ text: String) {
        let mv = MessageView(text: text, role: .user)
        stackView.addArrangedSubview(mv)
    }
    
    private func addAssistantMsgViewToStackView(_ text: String) -> MessageView {
        let mv = MessageView(text: text, role: .assistant)
        stackView.addArrangedSubview(mv)
        return mv
    }
    
    private func setupModelOptions(_ models: [OpenAI.Model]) {
        modelsPopUpBtn.removeAllItems()
        models.forEach { model in
            modelsPopUpBtn.addItem(withTitle: model.id)
        }
    }
    
    private func updateStatusView() {
        if stackMsgViews.isEmpty {
            statusView.isHidden = false
        } else {
            statusView.isHidden = true
        }
    }
}
