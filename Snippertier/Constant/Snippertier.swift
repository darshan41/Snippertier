//
//  Snippertier.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 13/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import Foundation

class SnippertierApp {
    
    static let shared: SnippertierApp = SnippertierApp()
    
    var shouldPauseMonitering: Bool = false
    
    private init() { }
}
