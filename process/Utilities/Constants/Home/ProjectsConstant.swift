//
//  ProjectsHomeConstant.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//

import Foundation


/** Centralized helper class for Project related views and models. */
class ProjectsConstant {
    
    /* MARK: ProjectsView */
    
    // Search bar
    public static let searchBarText: String = "Find a project..."
    
    // Segmented picker
    public static let pickerAccessibilityText = "Project category"
    public static let projectCategories: [String] = ["WIP", "Done"]
    public static let startingProjectCategory: Int = 0
    
    // Navigation bar
    public static let notificationsButtonIcon: String = "envelope.fill"
    public static let notificationsAccessibilityText: String = "Notifications"
    public static let navigationTitle: String = "Projects"
    
    // Banner messages
    public static let genericErrorBannerTitle: String = "Error"
}
