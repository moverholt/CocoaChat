//
//  AppDelegate.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesWindowController: PreferencesWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        ChatWindowManager.shared.openNewEmptyFullChatWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func onClickFileNew(_ sender: Any) {
        ChatWindowManager.shared.openNewEmptyFullChatWindow()
    }
    
    @IBAction func onClickPreferences(_ sender: Any) {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }
        preferencesWindowController?.showWindow(nil)
    }
}

