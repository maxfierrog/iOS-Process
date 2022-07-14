//
//  User.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import Foundation


class User {
    
    /* Fields */
    
    static let availableUserAttributes: Array<String> = ["username",
                                                         "screenName",
                                                         "email"]
    
    public var id: String
    public var attributes: Dictionary<String, String> = [:]
    
    /* Methods */
    
    init() {
        id = UUID.init().uuidString
    }
    
    init(attributesDict: Dictionary<String, String>) {
        id = UUID.init().uuidString
        addAttributesWithDictionary(attributesDict)
    }
    
    func addAttributesWithDictionary(_ attributesDict: Dictionary<String, String>) {
        guard keysAreUserAttributes(attributesDict) else { return }
        self.attributes = attributesDict
    }
    
    private func keysAreUserAttributes(_ dictionary: Dictionary<String, String>) -> (Bool) {
        for (key, _) in dictionary {
            guard User.availableUserAttributes.contains(key) else {
                return false
            }
        }
        return true
    }
}
