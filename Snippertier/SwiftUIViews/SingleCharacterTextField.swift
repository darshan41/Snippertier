//
//  SingleCharacterTextField.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import SwiftUI

struct SingleCharacterTextField: View {
    
    let currentCharacter: Character
    let onUpdate: (Character) -> Void
    
    @State private var text: String = ""
    @State private var isErrored: Bool = false
    
    var body: some View {
        ZStack {
            if isErrored {
                VStack {
                    Text("Please Enter Single Character, Empty or more than one character and it should be ASCII character is not permitted!")
                        .padding()
                    Spacer()
                    Button("Update") {
                        text = ""
                        isErrored = false
                    }
                }
            } else {
                VStack {
                    TextField("Enter a single character", text: $text)
                        .frame(width: 200, height: 30)
                        .padding()
                        .onChange(of: text, { oldValue, newValue in
                            if newValue.count > 1 {
                                text = String(newValue.prefix(1))
                            }
                        })
                    Button("Update") {
                        if text.count == 1 {
                            let character = Character(String(text.first!))
                            guard isASCIICharacter(character) else {
                                isErrored = true
                                return
                            }
                            onUpdate(character)
                        } else {
                            isErrored = true
                        }
                    }.padding(.bottom)
                }
            }
        }.onAppear {
            text = String(self.currentCharacter)
        }
    }
    
    func isASCIICharacter(_ character: Character) -> Bool {
        guard let scalar = character.unicodeScalars.first else {
            return false
        }
        let asciiValue = scalar.value
        return asciiValue < 128
    }
}

#Preview {
    SingleCharacterTextField(currentCharacter: "a", onUpdate: { character in
        print(character)
    })
}




