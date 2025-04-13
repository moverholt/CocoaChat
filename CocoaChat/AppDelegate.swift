//
//  AppDelegate.swift
//  CocoaChat
//
//  Created by Matt Overholt on 2/9/25.
//

import Cocoa
import Carbon
import Carbon.HIToolbox

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesWindowController: PreferencesWindowController?
    private var statusItem: NSStatusItem?
    private let statusMenu = NSMenu()
    private var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerGlobalHotkey()
        ChatWindowManager.shared.openNewEmptyFullChatWindow()
        createStatusItem()
        setupMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        unregisterGlobalHotkey()
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
        statusMenu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(quitApp(_:)),
                keyEquivalent: "q"
            )
        )
    }
    
    private func showMenu() {
        if let button = statusItem?.button {
            statusItem?.menu = statusMenu
            button.performClick(nil)
            statusItem?.menu = nil
        }
    }
    
    @objc private func quitApp(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
    
    private func registerGlobalHotkey() {
        let eventHotKeyID = EventHotKeyID(
            signature: OSType(UInt32(truncatingIfNeeded: "htk1".fourCharCodeValue)),
            id: UInt32(1)
        )
        
        let modifierKeys: UInt32 = UInt32((cmdKey | shiftKey))
        let keyCode = UInt32(kVK_ANSI_X)
        
        RegisterEventHotKey(
            keyCode,
            modifierKeys,
            eventHotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, _ in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout.size(ofValue: hotKeyID),
                    nil,
                    &hotKeyID
                )
                
                if hotKeyID.signature == OSType(
                    UInt32(truncatingIfNeeded: "htk1".fourCharCodeValue)
                ) {
                    print("✅ Global hotkey Command+Shift+X pressed")
                    ChatWindowManager.shared.openEmptyFloatingChatWindow()
                }
                
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
    
    private func unregisterGlobalHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}

