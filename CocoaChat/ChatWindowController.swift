//
//  ChatWindowController.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/1/25.
//

import Cocoa

class ChatWindowController: NSWindowController {
    let thread: Thread!
    let streaming: OpenAIStreaming!
    
    init(_ thread: Thread, _ streaming: OpenAIStreaming) {
        self.thread = thread
        self.streaming = streaming
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        contentViewController = ChatViewController(thread: thread, streaming: streaming)
    }
    
    var chatViewController: ChatViewController {
        contentViewController as! ChatViewController
    }
}
