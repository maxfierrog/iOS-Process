//
//  Task.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import Foundation

enum TaskSize: String {
    case small = "small"
    case medium = "medium"
    case big = "big"
}

public struct Task: Codable {
    
    var name: String
    var size: String?
    var description: String?
    var dateCreated: String
    var dateDue: String?
    var dateCompleted: String?
    var assignee: String?
    var creator: User
    var project: Project?
    var subtasks: Array<Task>
    
    enum CodingKeys: String, CodingKey {
        case name
        case size
        case description
        case dateCreated
        case dateDue
        case dateCompleted
        case assignee
        case creator
        case project
        case subtasks
    }
}
