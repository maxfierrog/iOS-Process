//
//  ValidationUtils.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import Foundation
import ActionButton

class ValidationUtils {
    
    static public let enabledLoginButtonState: ActionButtonState =
        .enabled(title: "Login", systemImage: "checkmark.circle")
    static public let invalidLoginButtonState: ActionButtonState =
        .disabled(title: "Please enter valid credentials", systemImage: "person.text.rectangle")
    static public let failedLoginButtonState: ActionButtonState =
        .disabled(title: "Invalid login information", systemImage: "person.fill.xmark")
    static public let loadingLoginButtonState: ActionButtonState =
        .loading(title: "Logging in...", systemImage: "person.fill.questionmark")
    static public let successLoginButtonState: ActionButtonState =
        .disabled(title: "Success!", systemImage: "person.fill.checkmark")
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}
