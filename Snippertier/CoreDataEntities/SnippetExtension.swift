//
//  SnippetExtension.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import CoreData

extension Snippet {
    
    static func nameFilterSortPredicate(_ query: String) -> (NSCompoundPredicate?, [NSSortDescriptor]?) {
        let caseInsensitiveNameKeyPath = \Snippet.content
        guard !query.isEmpty else {
            let nameSortDescriptor = NSSortDescriptor(key: caseInsensitiveNameKeyPath._kvcKeyPathString!, ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            return (nil,[nameSortDescriptor])
        }
        let caseInsensitiveNamePredicate = NSPredicate(format: "%K CONTAINS[c] %@", caseInsensitiveNameKeyPath._kvcKeyPathString!, query)
        let nameSortDescriptor = NSSortDescriptor(key: caseInsensitiveNameKeyPath._kvcKeyPathString!, ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [caseInsensitiveNamePredicate])
        return (compoundPredicate, [nameSortDescriptor])
    }
    
    func matches(_ string: String) -> Bool {
        guard let trigger else { return false }
        let hasSuffix = string.hasSuffix(trigger)
        let isBoundary = (string.dropLast(trigger.count).last ?? " ").isWhitespace
        return hasSuffix && isBoundary
    }
    
    @nonobjc
    public class func withDefaultValues(in context: NSManagedObjectContext) -> Snippet {
        let snippet = Snippet(context: context)
        snippet.date = Date()
        snippet.id = UUID().uuidString
        snippet.isABigContent = false
        return snippet
    }
    
    
    @nonobjc
    @discardableResult
    public class func insertWith(
        in context: NSManagedObjectContext,
        trigger: String,
        content: String,
        description: String
    ) -> Snippet {
        let snippet = Snippet.withDefaultValues(in: context)
        snippet.trigger = trigger
        snippet.content = content
        snippet.desc = description
        snippet.isABigContent = content.count > 30
        context.insert(snippet)
        return snippet
    }
    
    @nonobjc
    @discardableResult
    public class func insertWithSave(
        in context: NSManagedObjectContext,
        trigger: String,
        content: String,
        description: String
    ) throws -> Snippet {
        let snippet = Snippet.insertWith(in: context, trigger: trigger, content: content, description: description)
        try context.save()
        return snippet
    }
}

extension Snippet: TableObject {
    
    var text: String? { self.trigger }
}

