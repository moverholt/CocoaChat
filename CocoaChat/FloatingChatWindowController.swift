//
//  FloatingChatWindowController.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Cocoa

class FloatingChatWindowController: ChatWindowController, NSMenuItemValidation {
    @IBAction func toggleChatWindowType(_ sender: Any?) {
        ChatWindowManager.shared.moveToFullChatWindow(self)
    }
    
    override var windowNibName: NSNib.Name? {
        NSNib.Name("FloatingChatWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.setFrameAutosaveName("FloatingChatWindow")
    }
    
    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        if item.action == #selector(toggleChatWindowType(_:)) {
            item.title = "Toggle Full Chat Window"
        }
        return true
    }
}
