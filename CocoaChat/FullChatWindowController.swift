    //
    //  FullChatWindowController.swift
    //  CocoaChat
    //
    //  Created by Matt Overholt on 2/9/25.
    //

import Cocoa


class FullChatWindowController: ChatWindowController, NSMenuItemValidation {
    @IBAction func toggleChatWindowType(_ sender: Any?) {
        ChatWindowManager.shared.moveToFloatingChatWindow(self)
    }
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name("FullChatWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.setFrameAutosaveName("FullChatWindow")
    }
    
    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        if item.action == #selector(toggleChatWindowType(_:)) {
            item.title = "Toggle Floating Chat Window"
        }
        return true
    }
}
