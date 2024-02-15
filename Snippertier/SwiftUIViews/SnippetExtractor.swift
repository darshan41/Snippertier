//
//  SnippetExtractor.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import SwiftUI

struct SnippetValue {
    let trigger: String
    let content: String
    let description: String
}

struct SnippetExtractor: View {
    @State private var trigger: String = ""
    @State private var content: String = ""
    @State private var description: String = ""
    @State private var showErrorPopup = false
    
    let onUpdate: ((Snippet?,SnippetValue) -> Void)
    
    let snippet: Snippet?
    
    var body: some View {
        if showErrorPopup {
            ErrorPopupView(errorMessage: "All TextField Are To be Filled...") { value in
                showErrorPopup = value
            }
        } else {
            VStack {
                TextField("Trigger", text: $trigger)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Content", text: $content)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Description", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                if snippet == nil {
                    Button("Save") {
                        saveOrUpdate()
                    }
                    .frame(maxWidth: .infinity) // Match other elements' width
                } else {
                    Button("Update") {
                        saveOrUpdate()
                    }
                    .frame(maxWidth: .infinity)
                }
            }.frame(width: 300)
                .padding()
                .onAppear {
                    if let snippet = snippet {
                        trigger = String((snippet.trigger ?? "x").dropFirst())
                        content = snippet.content ?? ""
                        description = snippet.desc ?? ""
                    }
                }
        }
    }
    
    private func saveOrUpdate() {
        if trigger.isEmpty || content.isEmpty || description.isEmpty {
            showErrorPopup = true
        } else {
            self.onUpdate(self.snippet, SnippetValue(trigger: trigger, content: content, description: self.description))
        }
    }
}

struct ErrorPopupView: View {
    
    let errorMessage: String
    
    let onOk: ((Bool) -> Void)
    
    var body: some View {
        VStack {
            Text("Error")
                .font(.title)
            Text(errorMessage)
                .multilineTextAlignment(.center)
            Button("OK") {
                onOk(false)
            }
        }.frame(width: 300)
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


