//
//  CustomAlert.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import Cocoa

class CustomAlert {
    
    var customTitle: String?
    var alert: NSAlert?
    
    init(title: String) {
        self.customTitle = title
        self.alert = NSAlert()
        self.alert?.messageText = title
        self.alert?.alertStyle = .informational
        self.alert?.addButton(withTitle: "OK")
        self.alert?.buttons.first?.target = self
        self.alert?.buttons.first?.action = #selector(okButtonClicked)
    }
    
    func show() {
        if let window = NSApp.mainWindow {
            self.alert?.beginSheetModal(for: window) { _ in }
        } else {
            self.alert?.runModal()
        }
    }
    
    @objc func okButtonClicked() {
        self.alert?.window.orderOut(nil)
        NSApp.stopModal()
    }
}
