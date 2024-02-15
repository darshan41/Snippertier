//
//  CoreSnippertier.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import Foundation

let snippetDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d yyyy, h:mm a"
    return formatter
}()


func loadJson<T: Codable>(from url: URL,decoder: JSONDecoder = JSONDecoder()) throws -> T {
    let data = try Data(contentsOf: url)
    print(T.self)
    return try decoder.decode(T.self, from: data)
}

