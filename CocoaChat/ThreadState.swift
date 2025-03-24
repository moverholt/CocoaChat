//
//  Thread.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/2/25.
//

import Foundation

struct ThreadState {
    let messages: [Message]
    let streamingMsg: Message?
    let modelId: String
    
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
        } else {
            streamingMsg = nil
        }
        modelId = chatController.modelId
    }
}
