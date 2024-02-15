//
//  CustomSearchBar.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import SwiftUI

fileprivate struct SearchHelper {
    
    static let searchImage: String = "magnifyingglass"
    static let searchPlaceHolder: String = "Search"
    
}

struct CustomSearchBar<T: TableObject,E: TableObservableObject>: View where E.T == T {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var searchData: SearchModel<T,E>
    
    var onContentOffSetYChange: ((CGFloat) -> Void)?
    
    @State private var offset = CGFloat.zero
    
    var body: some View {
        let fillColor = Color.fillColor(colorScheme)
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: SearchHelper.searchImage)
                    .font(.title2)
                    .foregroundStyle(fillColor)
                    .padding(.leading,10)
                TextField(SearchHelper.searchPlaceHolder,text: $searchData.query)
                    .placeholder(when: searchData.query.isEmpty) {
                        Text(SearchHelper.searchPlaceHolder).foregroundColor(fillColor)
                    }
                    .padding(.vertical,10)
                    .foregroundStyle(fillColor)
                    .frame(alignment: .leading)
                    .padding(.horizontal,10)
            }
            .background(Color.fillOppositeColor(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
            if !searchData.searchedObjects.isEmpty {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading,spacing: 12) {
                        ForEach(searchData.searchedObjects, id: \.id) { object in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(object.text ?? "Unknown")
                                Divider()
                                    .background(fillColor)
                            }
                            .padding(.horizontal)
                        }
                    }.padding(.top)
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.y)
                        })
                }
                .onPreferenceChange(ViewOffsetKey.self) {
                    onContentOffSetYChange?($0)
                    print("offset >> \($0)") }
                .coordinateSpace(name: "scroll")
            } else {
                Text("No Results for \(searchData.query) has been found.")
                    .foregroundStyle(Color.fillOppositeColor(colorScheme))
                    .frame(alignment: .center)
                    .padding()
                    .onAppear {
                        self.onContentOffSetYChange?(0)
                    }
            }
        }
    }
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

