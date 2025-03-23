//
//  ChatWindowManager.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Foundation


class ChatWindowManager: ThreadDelegate {
    static let shared = ChatWindowManager()
    
    private var windows: [FullChatWindowController] = []
    private var floatingWindow: FloatingChatWindowController?
    
    func openNewFullChatWindow(_ thread: Thread, _ streaming: OpenAIStreaming) {
        let cont = FullChatWindowController(thread, streaming)
        cont.showWindow(nil)
        windows.append(cont)
        thread.delegate = self
    }
    
    func moveToFloatingChatWindow(_ cont: FullChatWindowController) {
        cont.close()
        windows.removeAll { $0 === cont }
        floatingWindow?.close()
        floatingWindow = FloatingChatWindowController(cont.thread, cont.streaming)
        floatingWindow?.showWindow(nil)
    }
    
    private func debug() {
        print("Windows: \(windows.count)")
    }
    
//    func openNewFloatingChatWindow(_ thread: Thread) {
//        floatingWindow?.close()
//        floatingWindow = FloatingChatWindowController(thread, OpenAIStreaming())
//        floatingWindow?.showWindow(nil)
//    }
    
    func moveToFullChatWindow(_ cont: FloatingChatWindowController) {
        floatingWindow?.close()
        openNewFullChatWindow(cont.thread, cont.streaming)
    }
    
    func onThreadChange(thread: Thread) {
        print("Thread change", thread.id)
    }
    
    func openNewEmptyFullChatWindow() {
        openNewFullChatWindow(Thread(), OpenAIStreaming())
    }
}
