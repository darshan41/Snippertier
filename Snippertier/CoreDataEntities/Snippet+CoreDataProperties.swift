//
//  Snippet+CoreDataProperties.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Foundation
import CoreData

extension Snippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Snippet> {
        return NSFetchRequest<Snippet>(entityName: "Snippet")
    }

    @NSManaged public var trigger: String?
    @NSManaged public var content: String?
    @NSManaged public var isABigContent: Bool
    @NSManaged public var desc: String?
    @NSManaged public var id: String
    @NSManaged public var date: Date

}

extension Snippet : Identifiable {
    
}
