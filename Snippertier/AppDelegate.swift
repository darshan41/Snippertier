//
//  AppDelegate.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet private weak var menu: NSMenu!
    @IBOutlet private weak var quitApp: NSMenuItem!
    @IBOutlet private weak var controlPanel: NSMenuItem!
    @IBOutlet private weak var pauseMonitering: NSMenuItem!
    @IBOutlet private weak var importMenuItem: NSMenuItem!
    @IBOutlet private weak var exportMenuItem: NSMenuItem!
    
    private let shared: SnippertierApp = .shared
    
    private var isImportingOrExporting: Bool = false
    
    private var alert: CustomAlert? {
        didSet {
            alert?.show()
        }
    }
    
    private var isShown: Bool = false {
        didSet {
            if !isShown {
                presentedControllerOnTop = nil
                controlPanel.title = "Open Store Panel"
            } else {
                controlPanel.title = "Close Store Panel"
            }
        }
    }
    
    private lazy var statusItem: NSStatusItem = {
        NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()
    
    private let manager: NSEventsManager = NSEventsManager()
    
    private var windowViewController: CoreWindowController?
    
    weak private var presentedControllerOnTop: NSWindowController?
    
    private var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initStatusItem()
        PermissionsService.acquireAccessibilityPrivileges()
        setupWindow()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        handleQuit()
    }
    
    @IBAction private func didTapLaunchAtLogin(_ sender: Any) {
        return
    }
    
    @IBAction private func didTapQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction private func onPressControlPanel(_ sender: Any) {
        if let presentedControllerOnTop {
            if isShown {
                presentedControllerOnTop.close()
                self.windowViewController = nil
                isShown = false
            } else {
                presentedControllerOnTop.showWindow(self)
                window?.makeKeyAndOrderFront(self)
                isShown = true
            }
        } else {
            guard let window = window else { return }
            let windowViewController = CoreWindowController.init(manager)
            self.windowViewController = windowViewController
            windowViewController.showWindow(self)
            window.makeKeyAndOrderFront(self)
            presentedControllerOnTop = windowViewController
            isShown = true
        }
    }
    
    @IBAction private func onTapPause(_ sender: Any) {
        shared.shouldPauseMonitering.toggle()
        if !shared.shouldPauseMonitering {
            pauseMonitering.title = "Pause"
        } else {
            pauseMonitering.title = "Resume"
        }
    }
    
    @IBAction private func onTapImportItem(_ sender: Any) {
        guard !isImportingOrExporting else { return }
        isImportingOrExporting = true
        beginImporting()
    }
    
    @IBAction private func onTapExportItem(_ sender: Any) {
        guard !isImportingOrExporting else { return }
        isImportingOrExporting = true
        beginExporting()
    }
}

// MARK: Helper func's

private extension AppDelegate {
    
    @objc
    func handleQuit() {
        NSApplication.shared.terminate(nil)
    }
    
    func setupWindow() {
        let window = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        self.window = window
    }
    
    func initStatusItem() {
        if let icon = NSImage(systemSymbolName: "character.book.closed.fill", accessibilityDescription: nil) {
            icon.isTemplate = true
            statusItem.button?.image = icon
        }
        statusItem.menu = self.menu
    }
    
    func beginImporting() {
        let model = ImportExportViewModel(managedObjectContext: self.manager.coreDataStack.managedContext)
        let filePicker = NSOpenPanel()
        alert = nil
        filePicker.canChooseFiles = true
        filePicker.canChooseDirectories = false
        filePicker.allowsMultipleSelection = false
        filePicker.allowedContentTypes = [.json]
        filePicker.begin { [weak self] response in
            guard let self else { return }
            if response == .OK, let url = filePicker.url {
                do {
                    try model.importData(from: url)
                    try self.manager.didChangeAlphaIdentifier()
                    self.manager.updateSnippets()
                } catch {
                    self.alert = CustomAlert(title: error.localizedDescription)
                }
                NotificationCenter.postDefault(.userDefinedNotification(.didChangeData))
            }
            self.isImportingOrExporting = false
        }
    }
    
    func beginExporting() {
        alert = nil
        let model = ImportExportViewModel(managedObjectContext: self.manager.coreDataStack.managedContext)
        let filePicker = NSSavePanel()
        filePicker.allowedContentTypes = [.json]
        filePicker.begin { response in
            if response == .OK, let url = filePicker.url {
                do {
                    try model.exportData(to: url)
                } catch {
                    self.alert = CustomAlert(title: error.localizedDescription)
                }
            }
            self.isImportingOrExporting = false
        }
    }
}


extension AppDelegate: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline) {
            textView.insertNewlineIgnoringFieldEditor(nil)
            return true
        }
        return false
    }
}
