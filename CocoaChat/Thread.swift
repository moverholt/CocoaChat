//
//  Thread.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/2/25.
//

import Foundation

protocol ThreadDelegate {
    func onThreadChange(thread: Thread)
}

class Thread: Equatable, Identifiable {
    let id = UUID()
    
    var delegate: ThreadDelegate?
    
    private var msgs: [Message] = []
    private var streamingMsg: Message?
    
    var messages: [Message] {
        msgs + [streamingMsg].compactMap { $0 }
    }
    
    enum Role {
        case user, assistant
    }
    
    struct Message: Identifiable {
        let id = UUID()
        let sender: Role
        var text: String
    }
    
    static func == (lhs: Thread, rhs: Thread) -> Bool {
        lhs.id == rhs.id
    }
    
    func addUserMessage(_ text: String) {
        let msg = Message(sender: .user, text: text)
        msgs.append(msg)
    }
    
    func startStreamingMsg(_ text: String) {
        streamingMsg = Message(sender: .assistant, text: text)
    }
    
    func debug() {
        print("Thread: \(id.description)")
        print("Messages: \(messages.count)")
    }
    
    func endStreamingMsg(_ text: String) {
        guard var msg = streamingMsg else { return }
        msg.text = text
        msgs.append(msg)
        streamingMsg = nil
    }
    
    var streaming: Bool {
        streamingMsg != nil
    }
    
    func updateStreamingMsg(_ text: String) {
        streamingMsg?.text = text
    }
}
