//
//  TasksConstant.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//

import Foundation


/** Centralized helper class for Task related views and models. */
class TasksConstant: GlobalConstant {
    
    /* MARK: TasksView */
    
    // Search bar
    public static let searchBarText: String = "Find a task..."
    
    // Segmented picker
    public static let pickerAccessibilityText = "Task category"
    public static let taskCategories: [String] = ["New", "WIP", "Done"]
    public static let startingTaskCategory: Int = 0
    
    // Navigation bar
    public static let exportButtonIcon: String = "square.and.arrow.up"
    public static let exportAccessibilityText: String = "Export tasks"
    public static let navigationTitle: String = "Tasks"
    
}
