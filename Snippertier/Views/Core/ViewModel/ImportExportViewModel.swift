//
//  ImportExportViewModel.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 14/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//

import Foundation
import CoreData

class ImportExportViewModel {
    
    private let managedObjectContext: NSManagedObjectContext
    
    private var decoder: JSONDecoder {
        get throws {
            let decoder = JSONDecoder()
            let codingInfoKey: CodingUserInfoKey? = .default
            guard codingInfoKey != nil else {
                throw CoreDataStack.Error.missingManagedObjectContext
            }
            decoder.userInfo = [codingInfoKey!: managedObjectContext]
            return decoder
        }
    }
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func importData(from url: URL) throws {
        let decoder = try self.decoder
        let snippets: [Snippet] = try loadJson(from: url,decoder: decoder)
        for snippet in snippets {
            addSnippet(snippet)
        }
        try managedObjectContext.save()
    }
    
    func exportData(to url: URL) throws {
        let snippets = try managedObjectContext.fetch(Snippet.fetchRequest())
        try snippets.encodeAndWrite(to: url)
    }
}

// MARK: Helper func's

private extension ImportExportViewModel {
    
    func addSnippet(_ snippet: Snippet) {
        let newSnippet = Snippet(context: managedObjectContext)
        newSnippet.trigger = snippet.trigger
        newSnippet.content = snippet.content
        newSnippet.isABigContent = snippet.isABigContent
        newSnippet.desc = snippet.desc
        newSnippet.id = snippet.id
        newSnippet.date = snippet.date
    }
}

extension Array where Element: Encodable {
    
    func encodeAndWrite(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: url)
    }
}
