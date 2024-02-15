//
//  Array.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import Foundation

extension Array {
    
    subscript(safe index: Index) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

