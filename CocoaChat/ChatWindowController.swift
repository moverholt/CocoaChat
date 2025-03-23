//
//  ChatWindowController.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/1/25.
//

import Cocoa

class ChatWindowController: NSWindowController {
    let streaming: OpenAIStreaming!
    private var initalThreadState: ThreadState?
    
    init(_ thread: ThreadState?, _ streaming: OpenAIStreaming) {
        self.streaming = streaming
        self.initalThreadState = thread
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        contentViewController = ChatViewController(
            thread: initalThreadState,
            streaming: streaming
        )
    }
    
    var chatViewController: ChatViewController {
        contentViewController as! ChatViewController
    }
    
    var threadState: ThreadState {
        chatViewController.threadState
    }
}
