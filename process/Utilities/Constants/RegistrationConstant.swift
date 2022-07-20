//
//  RegistrationConstant.swift
//  process
//
//  Created by maxfierro on 7/20/22.
//


import Foundation
import ActionButton


/** Centralized helper class for Register view and model constants. */
class RegistrationConstant {
    
    /* MARK: Register view constants */
    
    static public let navigationTitle: String = "Register"
    static public let welcomeMessage: String = "We'll just need a few things..."
    static public let welcomeIcon: String = "list.bullet.rectangle.fill"
    
    /* MARK: Register button states */
    
    static public let loadingRegisterButtonState: ActionButtonState =
        .loading(title: "One second...", systemImage: "")
    static public let enabledRegisterButtonState: ActionButtonState =
        .enabled(title: "Register!", systemImage: "arrow.up.and.person.rectangle.portrait")
    static public let invalidRegisterButtonState: ActionButtonState =
        .disabled(title: "Please fill out all the fields", systemImage: "rectangle.and.pencil.and.ellipsis")
    static public let failedRegisterButtonState: ActionButtonState =
        .disabled(title: "Could not register user", systemImage: "person.fill.xmark")
    static public let successRegisterButtonState: ActionButtonState =
        .disabled(title: "Success!", systemImage: "person.fill.checkmark")

}
