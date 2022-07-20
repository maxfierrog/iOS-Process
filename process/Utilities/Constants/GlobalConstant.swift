//
//  GlobalConstant.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//

import Foundation
import SwiftUI


/** Collection of constants used application wide. */
class GlobalConstant {

    /** Accent color for highlighted text, navigation buttons, etc. */
    public static let accentColor: Color = Color(.label)
    
    /** Text for the log out button at the top left of the home views. */
    public static let logoutButtonText: String = "Log Out"
    
    /** Message displayed on banner when log out fails. */
    public static let logOutFailedBannerMessage: String = "Failed to log out. Please try again shortly."
}
