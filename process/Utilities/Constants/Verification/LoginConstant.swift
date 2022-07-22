//
//  LoginConstant.swift
//  process
//
//  Created by maxfierro on 7/20/22.
//


import Foundation
import ActionButton


/** Centralized helper class for Login view and model constants. */
class LoginConstant: GlobalConstant {
    
    /* MARK: LoginView */
    
    // Text fields and icons
    public static let navigationTitle: String = "Login"
    public static let welcomeMessage: String = "Welcome to Process!"
    public static let welcomeIcon: String = "person.fill"
    public static let registerButtonTitle: String = "Register"
    public static let registerButtonIcon: String = "list.bullet.rectangle"
    public static let forgotPasswordButtonText: String = "Forgot password"
    
    // Login button states
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
    
    // Banner messages
    public static let invalidEmailForResetText: String = "Please enter a valid email address."
    public static let recoveryEmailSentText: String = "We have sent a recovery link to the account associated with that email address, if there is one."
    public static let recoveryEmailSentBannerTitle: String = "Email sent"

}
