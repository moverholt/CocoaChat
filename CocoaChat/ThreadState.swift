//
//  Thread.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/2/25.
//

import Foundation

struct ThreadState: Equatable, Identifiable {
    let id = UUID()
    private(set) var messages: [Message] = []
    private(set) var streamingMsg: Message?
    
    enum Role {
        case user, assistant
    }
    
    struct Message: Identifiable {
        let id = UUID()
        let sender: Role
        var text: String
    }
    
    init(_ chatController: ChatViewController) {
        messages = chatController.stackMsgViews.map { mv in
            Message(sender: mv.role, text: mv.text)
        }
        if let smv = chatController.streamingMsgView {
            streamingMsg = Message(sender: smv.role, text: smv.text)
        }
    }
    
    static func == (lhs: ThreadState, rhs: ThreadState) -> Bool {
        lhs.id == rhs.id
    }
}
