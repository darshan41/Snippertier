//
//  Constant.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Foundation

public struct Constant {
    
    public fileprivate(set) static var alphaIdentifier: Character = UserDefaultValues.alphaIdentifier.first ?? "x"
    
    public fileprivate(set) static var currentIdentifier: Character = UserDefaultValues.alphaIdentifier.first ?? "x"
    
    static func setAlphaIdentifier(_ character: String) {
        assert(character.first != nil)
        Constant.alphaIdentifier = character.first!
        UserDefaultValues.alphaIdentifier = character
        print(Constant.alphaIdentifier)
    }
    
    static func setCurrentAlphaIdentifier(_ character: String) {
        assert(character.first != nil)
        Constant.currentIdentifier = character.first!
        print(Constant.currentIdentifier)
    }
}
