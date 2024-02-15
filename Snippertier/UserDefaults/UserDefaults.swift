//
//  UserDefaultKeys.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Foundation

struct Info: Codable {
    let info: String
}

enum UserDefaultKeys: String,CaseIterable {
    
    /// Default Single Value Container Keys
    case hasSeenAppintro = "hasSeenAppintro"
    case alphaIdentifier = "alphaIdentifier"
    
    ///Optional Codable Container Keys
    
    case info = "info"
    
    fileprivate var appKey: String { "com.\(self.rawValue).appName" }
    
    fileprivate static func removeValuesRelatedToKeys() {
        Self.allCases.forEach({ UserDefaults.standard.removeObject(forKey: $0.appKey) })
    }
}

@propertyWrapper
struct UserDefault<Value> {
    
    let key: UserDefaultKeys
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            UserDefaults.standard.value(forKey: key.appKey) as? Value ?? self.defaultValue
        } set {
            UserDefaults.standard.set(newValue, forKey: key.appKey)
        }
    }
    
    var projectedValue: Self { self }
    
    func removeValue() {
        UserDefaults.standard.removeObject(forKey: key.appKey)
    }
}

@propertyWrapper
struct Plist<T: Codable> {
    
    let key: UserDefaultKeys
    let defaultValue: T?
    
    var wrappedValue: T? {
        get {
            guard let data = UserDefaults.standard.data(forKey: key.appKey),
                  let value = try? PropertyListDecoder().decode(T.self, from: data)
            else {
                return defaultValue
            }
            return value
        } set {
            if let newValue = newValue {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: key.appKey)
            } else {
                UserDefaults.standard.removeObject(forKey: key.appKey)
            }
        }
    }
    
    var projectedValue: Self { self }
    
    func removeValue() {
        UserDefaults.standard.removeObject(forKey: key.appKey)
    }
}

struct UserDefaultValues {
    
    @UserDefault(key: .hasSeenAppintro, defaultValue: false)
    static var hasSeenAppintro: Bool
    
    @UserDefault(key: .alphaIdentifier, defaultValue: "x")
    static var alphaIdentifier: String
    
    @Plist(key: .info, defaultValue: nil)
    static var info: Info?
    
    func removeAllValues() {
        UserDefaultKeys.removeValuesRelatedToKeys()
    }
}

