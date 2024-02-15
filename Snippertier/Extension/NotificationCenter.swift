//
//  NotificationCenter.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Foundation

// MARK: NotificationKeys

public enum NotificationKeys: String {
    case saveCoreDataStackInfo = "saveCoreDataStackInfo"
    case didChangeData = "didChangeData"
}

// MARK: NotificationHelper

enum NotificationHelper {
    
    case appNotification(Notification.Name)
    case userDefinedNotification(NotificationKeys)
    
    var getRaw: String {
        switch self {
        case .appNotification(let notificationName):
            return notificationName.rawValue
        case .userDefinedNotification(let notificationKeys):
            return notificationKeys.rawValue
        }
    }
}

extension NotificationCenter {
    
    static func addDefaultObserver(
        name: NotificationHelper,
        observer: Any,
        selector: Selector
    ) {
        Self.default.addObserver(observer, selector: selector, name: .init(name), object: nil)
    }
    
    
    static func removeDefaultObserver(
        name: NotificationHelper,
        _ observer: Any
    ) {
        Self.default.removeObserver(observer, name: .init(name), object: nil)
    }
    
    static func postDefault(_ name: NotificationHelper) {
        Self.default.post(
            name: .init(name),
            object: nil
        )
    }
}


extension Notification.Name {
    
    init(_ name: NotificationHelper) {
        self.init(rawValue: name.getRaw)
    }
}

