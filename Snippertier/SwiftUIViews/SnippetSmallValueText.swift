//
//  SwiftUIView.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import SwiftUI

struct SnippetSmallValueText: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
    }
}

#Preview {
    SnippetIntermidiateValueText(title: "SnippetSmallValueText")
}



