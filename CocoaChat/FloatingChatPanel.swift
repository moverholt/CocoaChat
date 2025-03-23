//
//  FloatingChatPanel.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/18/25.
//

import Cocoa

class FloatingChatPanel: NSPanel {
    private var floatingChatWindowController: FloatingChatWindowController {
        self.windowController as! FloatingChatWindowController
    }
    
    @IBAction func openAsFullChatWindow(_ sender: Any) {
        print("Open as full chat window")
        ChatWindowManager.shared.moveToFullChatWindow(floatingChatWindowController)
    }
}
