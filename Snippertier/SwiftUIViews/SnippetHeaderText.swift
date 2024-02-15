//
//  SwiftUIView.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import SwiftUI

struct SnippetHeaderText: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}


#Preview {
    SnippetHeaderText(title: "SnippetHeaderText")
}
