//
//  ChatWindowManager.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Foundation


class ChatWindowManager {
    static let shared = ChatWindowManager()
    
    private var windows: [FullChatWindowController] = []
    private var floatingWindow: FloatingChatWindowController?
    
    func openNewFullChatWindow(_ thread: ThreadState?, _ streaming: OpenAIStreaming) {
        let cont = FullChatWindowController(thread, streaming)
        cont.showWindow(nil)
        windows.append(cont)
    }
    
    func moveToFloatingChatWindow(_ cont: FullChatWindowController) {
        cont.close()
        windows.removeAll { $0 === cont }
        floatingWindow?.close()
        floatingWindow = FloatingChatWindowController(cont.threadState, cont.streaming)
        floatingWindow?.showWindow(nil)
    }

    func moveToFullChatWindow(_ cont: FloatingChatWindowController) {
        floatingWindow?.close()
        openNewFullChatWindow(cont.threadState, cont.streaming)
    }
    
    func openNewEmptyFullChatWindow() {
        openNewFullChatWindow(nil, OpenAIStreaming())
    }
}
