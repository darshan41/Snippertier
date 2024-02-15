//
//  View.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import SwiftUI

extension View {
    
    func frame(_ size: CGSize) -> some View {
        return frame(width: size.width, height: size.height)
    }
    
    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {
            placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(.gray) }
        }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

extension CGSize {
    
    func addingConstantValue(_ constant: CGFloat) -> CGSize {
        .init(width: width + constant, height: height + constant)
    }
}

