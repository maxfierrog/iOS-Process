//
//  LoginConstant.swift
//  process
//
//  Created by maxfierro on 7/20/22.
//


import Foundation
import ActionButton


/** Centralized helper class for Login view and model constants. */
class LoginConstant {
    
    /* MARK: Login view constants */
    
    public static let navigationTitle: String = "Login"
    public static let welcomeMessage: String = "Welcome to Process!"
    public static let welcomeIcon: String = "person.fill"
    public static let registerButtonTitle: String = "Register"
    public static let registerButtonIcon: String = "list.bullet.rectangle"
    public static let forgotPasswordButtonText: String = "Forgot password"
    
    /* MARK: Login button states */
    
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
    
}
