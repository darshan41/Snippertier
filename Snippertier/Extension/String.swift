//
//  String.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import Foundation

extension String {
    
    var triggeredValue: String {
        "\(Constant.alphaIdentifier)\(self)"
    }
}
