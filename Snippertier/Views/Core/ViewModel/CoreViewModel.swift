//
//  CoreViewModel.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Foundation
import SwiftUI

@MainActor
class SearchModel<T: TableObject,E: TableObservableObject>: ObservableObject where E.T == T {
    
    weak var tableObservable: E?
    
    @Published var searchedObjects: [T] = []
    @Published var query: String = ""
    @Published var page: Int = 1
    
    init(tableObservable: E) {
        self.tableObservable = tableObservable
    }
    
    func find() async {
        self.searchedObjects = await tableObservable?.findObjects(query) ?? []
    }
}
