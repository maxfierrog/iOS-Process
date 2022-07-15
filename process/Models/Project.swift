//
//  Project.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import Foundation

public struct Project: Codable {
    
    var name: String
    var description: String?
    var dateCreated: String
    var dateCompleted: String?
    var adminUsername: String
    var collaborators: Array<String>
    var tasks: Array<Task>
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case dateCreated
        case dateCompleted
        case adminUsername
        case collaborators
        case tasks
    }
}
