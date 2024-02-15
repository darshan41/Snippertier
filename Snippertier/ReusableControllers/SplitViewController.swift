//
//  SplitViewController.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import AppKit

final class SplitView: NSSplitView {
    
    override var dividerThickness: CGFloat { 0 }
}

final class SplitViewController: NSSplitViewController {
    
    override func loadView() {
        let splitView = SplitView()
        splitView.isVertical = true
        self.splitView = splitView
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        .zero
    }
}

// MARK: Helper func's

private extension SplitViewController {
    
    func configureView() {
        
    }
}
