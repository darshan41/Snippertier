//
//  Table.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import SwiftUI

protocol TableObject: Identifiable {
    var text: String? { get }
}

protocol TableObservableObject: ObservableObject {
    
    associatedtype T: TableObject
    
    func findObjects(_ queryString: String) async -> [T]
}

struct Table<T: TableObject,E: TableObservableObject>: View where E.T == T {
    
    let title: String
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject var searchData: SearchModel<T,E>
    
    @State private var shouldHide: Bool = false
        
    var body: some View {
        VStack {
            if !shouldHide {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(colorScheme.oppositeSchemeColor)
                    .opacity(shouldHide ? 0 : 1)
                    .animation(.easeInOut, value: 1)
            }
            CustomSearchBar<T, E>(searchData: searchData) { yOffset in
                if yOffset > 100 {
                    if shouldHide { return }
                    withAnimation {
                        shouldHide = true
                    }
                } else {
                    if !shouldHide { return }
                    withAnimation {
                        shouldHide = false
                    }
                }
            }
            Spacer()
        }
        .background(Color.fillColor(colorScheme))
        .onChange(of: searchData.query) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask(priority: .utility) {
                        await searchData.find()
                    }
                    try await group.waitForAll()
                }
            }
        }
        .task {
            await searchData.find()
        }
    }
}

