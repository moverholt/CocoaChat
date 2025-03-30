//
//  AppDelegate.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Cocoa
import Carbon
        

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesWindowController: PreferencesWindowController?
    private var statusItem: NSStatusItem?
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Task {
            let resp = await OpenAI.shared.models()
            switch resp {
            case .success(let models):
                print("Models:", models)
            case .failure(let err):
                print("Failed to get models: \(err)")
            }
            Task { @MainActor in
                ChatWindowManager.shared.openNewEmptyFullChatWindow()
                createStatusItem()
                setupMenu()
            }
        }
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
    
    private func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "bubble.left.and.bubble.right",
                accessibilityDescription: "Status Button"
            )
            button.imagePosition = .imageLeading
            button.action = #selector(handleStatusItemClick(_:))
            button.target = self
        }
        
        statusItem?.button?.toolTip = "Click me!"
    }
    
    @objc private func handleStatusItemClick(_ sender: Any?) {
        guard let currentEvent = NSApp.currentEvent else { return }
        if currentEvent.modifierFlags.contains(.option) {
            showMenu()
        } else {
            ChatWindowManager.shared.openEmptyFloatingChatWindow()
        }
    }
    
    private func setupMenu() {
        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(quitApp(_:)),
                keyEquivalent: "q"
            )
        )
    }
    
    private func showMenu() {
        if let button = statusItem?.button {
            statusItem?.menu = menu
            button.performClick(nil)
            statusItem?.menu = nil
        }
    }
    
    @objc private func quitApp(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
}

