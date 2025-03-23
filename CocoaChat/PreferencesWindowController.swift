//
//  PreferencesWindowController.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/23/25.
//

import Cocoa

class PreferencesWindowController:
    NSWindowController,
    NSTextFieldDelegate {
    let settings = UserSettings.shared

    @IBOutlet weak var openAIAPIKeyTextField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        openAIAPIKeyTextField.stringValue = settings.model.apiKey ?? ""
        openAIAPIKeyTextField.delegate = self
    }
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name("PreferencesWindowController")
    }
    
    func controlTextDidChange(_ obj: Notification) {
        print("controlTextDidChange")
        guard let field = obj.object as? NSTextField else {
            return
        }
        print("field.stringValue: \(field.stringValue)")
        
        if field == openAIAPIKeyTextField {
            settings.setApiKey(field.stringValue)
        }
    }
}
