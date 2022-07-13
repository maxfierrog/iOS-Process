//
//  ValidationUtils.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import Foundation
import ActionButton

class ValidationUtils {
    
    /* Login button states */
    
    static public let enabledLoginButtonState: ActionButtonState =
        .enabled(title: "Login", systemImage: "checkmark.circle")
    static public let invalidLoginButtonState: ActionButtonState =
        .disabled(title: "Please enter valid credentials", systemImage: "person.text.rectangle")
    static public let failedLoginButtonState: ActionButtonState =
        .disabled(title: "Invalid login information", systemImage: "person.fill.xmark")
    static public let loadingLoginButtonState: ActionButtonState =
        .loading(title: "Logging in...", systemImage: "")
    static public let successLoginButtonState: ActionButtonState =
        .disabled(title: "Success!", systemImage: "person.fill.checkmark")
    
    /* Register button states */
    
    static public let loadingRegisterButtonState: ActionButtonState =
        .loading(title: "One second...", systemImage: "")
    static public let enabledRegisterButtonState: ActionButtonState =
        .enabled(title: "Register!", systemImage: "arrow.up.and.person.rectangle.portrait")
    static public let invalidRegisterButtonState: ActionButtonState =
        .disabled(title: "Please fill out all the fields", systemImage: "rectangle.and.pencil.and.ellipsis")
    static public let failedRegisterButtonState: ActionButtonState =
        .disabled(title: "Could not register user", systemImage: "person.fill.xmark")
    
    /* Credentials validation */
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidUsername(_ username: String) -> Bool {
        // FIXME: Check if there is someone with this username in database
        return !username.isEmpty
    }
    
}
