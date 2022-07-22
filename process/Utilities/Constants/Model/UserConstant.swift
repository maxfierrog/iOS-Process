//
//  UserConstant.swift
//  process
//
//  Created by maxfierro on 7/20/22.
//


import Foundation


/** Centralized helper class for User model constants. */
class UserConstant: GlobalConstant {
    
    /* MARK: Field errors */
    
    /** This will be stored instead of an Authentication ID when registration
     succeeds in saving user data despite having failed to sign in the user.
     Used for diagnostics and backend fixes. */
    static public let noAuthenticatedUserAuthIDMessage: String = "NO-AUTH-USER-ERROR"
    
    /** This will be stored instead of an Authentication ID when registration
     succeeds in saving user data, but fails to fetch the signed-in user's
     Authentication ID for an indeterminate reason. Used for diagnostics and
     backend fixes. */
    static public let noAuthIDMessage: String = "ERROR"
    
    /** The path for the default profile picture image, which is presented
     for users which have not manually selected one. */
    static public let defaultProfilePicturePath = "default.jpg"
}
