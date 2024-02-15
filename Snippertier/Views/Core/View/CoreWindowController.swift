//
//  CoreWindowController.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa

class CoreWindowController: NSWindowController {
    
    private (set)var model: NSEventsManager!
    
    private let splitViewcontroller: SplitViewController = SplitViewController()
    private var listViewController: SnippetListViewController!
    private var infoViewController: SnippetInfoViewController!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        configureView()
    }
    
    required convenience init(_ eventManager: NSEventsManager) {
        self.init(windowNibName: NSNib.Name(String(describing: Self.self)))
        self.model = eventManager
    }
    
    deinit {
        debugPrint("💥 Deininting \(Self.self)")
    }
}

// MARK: Helper func's

private extension CoreWindowController {
    
    func configureView() {
        self.window?.isMovableByWindowBackground = true
        let listViewController = SnippetListViewController(model: model)
        self.listViewController = listViewController
        splitViewcontroller.addChild(listViewController)
        let infoViewController = SnippetInfoViewController()
        self.infoViewController = infoViewController
        listViewController.snippetDelegate = infoViewController
        splitViewcontroller.addChild(infoViewController)
        contentViewController = splitViewcontroller
    }
}
