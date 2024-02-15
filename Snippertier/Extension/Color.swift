//
//  Color.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import SwiftUI
import AppKit

import SwiftUI
import AppKit

extension ColorScheme {
    
    var isDark: Bool { self == .dark }
    
    var oppositeSchemeColor: Color {
        isDark ? .primaryLight : .primaryDark
    }
    
    var properSchemeColor: Color {
        isDark ? .primaryDark : .primaryLight
    }
}

extension NSColor { // Change to NSColor
    
    var toColor: Color { Color(self) }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }
}

extension Color {
    
    var toNSColor: NSColor { // Change to NSColor
        NSColor(self) // Change to NSColor
    }
    
    static func fillColor(_ scheme: ColorScheme) -> Color {
        scheme.properSchemeColor
    }
    
    static func fillOppositeColor(_ scheme: ColorScheme) -> Color {
        scheme.oppositeSchemeColor
    }
    
    static var currentScheme: ColorScheme {
        // Adjusting for macOS
        return NSApp?.effectiveAppearance.name == .darkAqua ? .dark : .light
    }
    
    
    static var oppositeSchemeColor: Color {
        // Adjusting for macOS
        Color.currentScheme == .dark ? .primaryLight : .primaryDark
    }
    
    static var properColor: Color {
        // Adjusting for macOS
        Color.currentScheme == .dark ? .primaryDark : .primaryLight
    }
    
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 224 / 255, green: 229 / 255, blue: 236 / 255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
}
