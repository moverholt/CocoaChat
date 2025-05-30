//
//  MyWindow.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/17/25.
//

import Cocoa

class FullChatWindow: NSWindow {
    
    private var fullChatWindowController: FullChatWindowController {
        self.windowController as! FullChatWindowController
    }

    @IBAction func onOpenAsFloatingWindow(_ sender: Any) {
        ChatWindowManager.shared.moveToFloatingChatWindow(
            self.fullChatWindowController
        )
    }
}
