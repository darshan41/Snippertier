//
//  TableView.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa

class TableView: NSTableView {
    
    override func keyDown(with event: NSEvent) {
        if event.characters?.count == 1,event.keyCode == 36 {
            sendAction(doubleAction, to: target)
        } else {
            super.keyDown(with: event)
        }
    }
}
