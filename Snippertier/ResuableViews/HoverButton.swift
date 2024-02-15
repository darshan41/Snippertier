//
//  HoverButton.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa

class HoverButton: NSButton {
    
    @IBInspectable var hoveringImage: NSImage?
    
    @IBInspectable var notHoveringImage: NSImage? {
        didSet {
            image = notHoveringImage
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addTrackingArea()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTrackingArea()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.image = hoveringImage
    }
    
    override func mouseExited(with event: NSEvent) {
        super.image = notHoveringImage
    }
}

// MARK: Helper func's

private extension HoverButton {
    
    func addTrackingArea() {
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited,.activeAlways,.inVisibleRect], owner: self, userInfo: nil))
    }
}
