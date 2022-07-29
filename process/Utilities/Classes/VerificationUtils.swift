//
//  ValidationUtils.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//


import Foundation


/** Helper class with utility methods for the user verification process. */
class VerificationUtils {
    
    /* MARK: Validation processing methods */
    
    /** Returns true if EMAIL is not malformed. */
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    /* MARK: Registration processing methods */
    
    /** Generates and passes a unique username RESULT based on a user screen
     NAME. This is ensured by adding an integer counter which only increases
     to the end of existing usernames to ensure uniqueness. */
    static func availableUsernameFromName(_ name: String, _ completion: @escaping(_ result: String?, _ error: Error?) -> Void) {
        let noWhitespaceName: String = String(name.filter { !" \n\t\r".contains($0) }).lowercased()
        APIHandler.matchUsernameQuery(noWhitespaceName) { query, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            if (!query!.documents.isEmpty) {
                APIHandler.getUsernameRepeatCount { count, error in
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    APIHandler.incrementUsernameRepeatCount()
                    completion(noWhitespaceName + String(count!), nil)
                }
            } else {
                completion(noWhitespaceName, nil)
            }
        }
    }
    
    /** Returns a new user data model with a unique EMAIL, unique USERNAME,
     and non-unique screen NAME. */
    static func getNewUserModel(name: String, username: String, email: String) -> UserData {
        return UserData(name: name,
                    username: username,
                    email: email)
    }
    
    /** Returns a placeholder user data model to temporarily satisfy fields. */
    static func getPlaceholderUser() -> UserData {
        return UserData()
    }
}
