//
//  ProfileConstant.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//

import Foundation


/** Centralized helper class for Profile related views and models. */
class ProfileConstant: GlobalConstant {
    
    /* MARK: ProfileView */
    
    // Profile page
    public static let defaultProfilePicture: String = "default-profile-picture"
    
    // Navigation bar
    public static let preferencesButtonIcon: String = "gearshape.fill"
    public static let preferencesAccessibilityText: String = "User preferences"
    public static let navigationTitle: String = "Profile"
    
    // Banner messages
    public static let usernameColisionError: String = "Sorry, that username already exists. Please choose another one."
    public static let successUpdatingData: String = "Successfully changed your user data."
    
}
