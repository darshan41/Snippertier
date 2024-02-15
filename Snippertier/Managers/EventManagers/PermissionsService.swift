//
//  PermissionsService.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa

final class PermissionsService: ObservableObject {

    @Published var isTrusted: Bool = AXIsProcessTrusted()
    func pollAccessibilityPrivileges() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isTrusted = AXIsProcessTrusted()
            if !self.isTrusted {
                self.pollAccessibilityPrivileges()
            }
        }
    }

    static func acquireAccessibilityPrivileges() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let enabled = AXIsProcessTrustedWithOptions(options)
        if !enabled {
            print("Access Not Enabled")
            exit(0)
        }        
    }
}
