//
//  CoreDataStack.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//



import AppKit
import CoreData

protocol ErrorShowable: Error,LocalizedError {
    var showableDescription: String { get }
}

extension ErrorShowable {
    var errorDescription: String? { showableDescription }
}

enum CoreDataModel: String,CaseIterable {
    case snippertier = "Snippertier"
}

protocol CoreDataStackManagible {
    
    var managedContext: NSManagedObjectContext { get }
    var newBackgroundContext: NSManagedObjectContext { get }
    
    func saveContext() throws
    
    var ignoreCoreDataNoChangeError: Bool { get }
    var shouldDeleteInaccessibleFaults: Bool { get }
}

class CoreDataStack {
    
    private let model: CoreDataModel
    private (set)var storeLoadError: NSError?
    
    var ignoreCoreDataNoChangeError: Bool { true }
    var shouldDeleteInaccessibleFaults: Bool { true }
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: model.rawValue)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.storeLoadError = error
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.shouldDeleteInaccessibleFaults = self.shouldDeleteInaccessibleFaults
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = { self.storeContainer.viewContext }()
    
    lazy var newBackgroundContext: NSManagedObjectContext = { self.storeContainer.newBackgroundContext() }()
    
    
    init(model: CoreDataModel) {
        self.model = model
        NotificationCenter.addDefaultObserver(name: .userDefinedNotification(.saveCoreDataStackInfo), observer: self, selector: #selector(saveChanges))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: CoreDataStackManagible

extension CoreDataStack: CoreDataStackManagible {
    
    // MARK: - Core Data Saving support
    
    func saveContext() throws {
        let context = managedContext
        guard context.hasChanges else {
            if ignoreCoreDataNoChangeError {
                return
            }
            throw Error.noChanges
        }
        do {
            try context.save()
        } catch {
            throw Error.custom(error.localizedDescription)
        }
    }
}

// MARK: Helper func's

private extension CoreDataStack {
    
    @objc func saveChanges() {
        try? saveContext()
    }
}

extension CoreDataStack {
    
    enum Error: ErrorShowable {
        case noChanges
        case custom(String)
        case missingManagedObjectContext
        
        var showableDescription: String {
            switch self {
            case .custom(let errorDesc):
                return errorDesc
            case .missingManagedObjectContext:
                return "Missing Managed Object Context this was not supposed to happen!"
            case .noChanges:
                return "No Core Data Changes"
            }
        }
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

public typealias CoreDataAsynchronousFetchResult<T: NSFetchRequestResult> = ((NSAsynchronousFetchResult<T>) -> Void)?

extension NSManagedObject {
    
    //    @nonobjc
    //    public class func coreEntity(in context: NSManagedObjectContext) throws -> NSEntityDescription {
    //        guard let entity = NSEntityDescription.entity(forEntityName: "\(Self.self)", in: context) else {
    //            throw CoreDataStack.Error.custom("No NSEntityDescription Found for entity named \("\(Self.self) on context: \(context.description)")")
    //        }
    //        return entity
    //    }
    
    //    @nonobjc
    //    public class func insertValues<T: NSManagedObject>(with expectedType: T.Type = T.self,in context: NSManagedObjectContext) throws {
    //        let entity = try T.coreEntity(in: context)
    //        entity.inser
    //    }
    
    @nonobjc
    public class func coreInsertRequest(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: "\(Self.self)", in: context) else {
            throw CoreDataStack.Error.custom("No NSEntityDescription Found for entity named \("\(Self.self) on context: \(context.description)")")
        }
        return entity
    }
    
    @nonobjc
    public class func coreFetchRequest<T: NSManagedObject>(expectedType: T.Type = T.self,_ entityName: String = "\(T.self)") -> NSFetchRequest<T> {
        NSFetchRequest<T>(entityName: entityName)
    }
    
    @nonobjc
    public class func coreFetchAsyncRequest<T>(
        _ request: NSFetchRequest<T>,
        onCompletion: CoreDataAsynchronousFetchResult<T>
    ) -> NSAsynchronousFetchRequest<T> {
        NSAsynchronousFetchRequest<T>.init(fetchRequest: request,completionBlock: onCompletion)
    }
    
    @nonobjc
    public class func coreFetchAsyncRequest<T>(
        _ request: NSFetchRequest<T>,
        in context: NSManagedObjectContext
    ) async throws -> [T] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = NSAsynchronousFetchRequest<T>.init(fetchRequest: request) { request in
                if let result = request.finalResult {
                    continuation.resume(with: .success(result))
                } else {
                    continuation.resume(with: .failure(CoreDataStack.Error.custom("Unable to get desired Results, Something went wrong!")))
                }
            }
            do {
                try context.execute(request)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}
