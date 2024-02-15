//
//  Snippet+CoreDataClass.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Foundation
import CoreData

@objc(Snippet)
public class Snippet: NSManagedObject,Codable {
    
    fileprivate enum CodingKeys: String,CodingKey {
        case trigger = "trigger"
        case content = "content"
        case isABigContent = "isABigContent"
        case desc = "desc"
        case id = "id"
        case date = "date"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trigger, forKey: .trigger)
        try container.encode(content, forKey: .content)
        try container.encode(isABigContent, forKey: .isABigContent)
        try container.encode(desc, forKey: .desc)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.default,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext else {
            throw CoreDataStack.Error.missingManagedObjectContext
        }
        self.init(context: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trigger = try container.decode(String.self, forKey: .trigger)
        content = try container.decode(String.self, forKey: .content)
        isABigContent = ((try? container.decodeIfPresent(Bool.self, forKey: .isABigContent)) ?? ((content ?? "").count > 30))
        desc = try container.decode(String.self, forKey: .desc)
        id = try container.decode(String.self, forKey: .id)
        if let date = try? container.decode(Date.self, forKey: .date) {
            self.date = date
        } else {
            if let dateStr = try? container.decode(String.self, forKey: .date),
               let date = snippetDateFormatter.date(from: dateStr) {
                self.date = date
            } else {
                self.date = Date()
            }
        }
    }
}

extension CodingUserInfoKey {
    static let `default` = CodingUserInfoKey(rawValue: "context")
}



