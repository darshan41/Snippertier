//
//  SnippetTextView.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 13/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import SwiftUI
class SnippetHolder: ObservableObject {
    @Published var snippet: Snippet?
}

struct SnippetView: View {
    @ObservedObject var snippetHolder: SnippetHolder = SnippetHolder()
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 10) { // Set alignment to .leading
                        if let snippet = snippetHolder.snippet {
                            SnippetHeaderText(title: "Trigger")
                            SnippetIntermidiateValueText(title:  String((snippet.trigger ?? "\(Constant.alphaIdentifier)Unknown").dropFirst()))
                            SnippetHeaderText(title: "Date")
                            SnippetIntermidiateValueText(title: "\(snippetDateFormatter.string(from: snippet.date))")
                            
                            SnippetHeaderText(title: "Trigger's Content")
                            SnippetIntermidiateValueText(title: snippet.content ?? "None?")
                            
                            SnippetHeaderText(title: "Description")
                            SnippetSmallValueText(title: snippet.desc ?? "None")
                        } else {
                            SnippetHeaderText(title: "No snippet available")
                        }
                    }
                }
                .frame(height: .infinity) // Set frame dimensions
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Align the ScrollView content to the leading edge
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Remove any padding
        }
    }
}
