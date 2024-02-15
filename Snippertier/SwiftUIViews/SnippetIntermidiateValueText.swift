//
//  SwiftUIView.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import SwiftUI

struct SnippetIntermidiateValueText: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
    }
}

#Preview {
    SnippetIntermidiateValueText(title: "SnippetIntermidiateValueText")
}



