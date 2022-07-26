//
//  Project.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import Foundation


class Project: Hashable {
    
    var data: ProjectData
    
    init(data: ProjectData) {
        self.data = data
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: Project, rhs: Project) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

public struct ProjectData: Codable {
    
    var id: String
    var name: String
    var owner: String
    var description: String?
    var dateCreated: String
    var dateCompleted: String?
    var collaborators: Array<String>
    var tasks: Array<String>
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case description
        case dateCreated
        case dateCompleted
        case collaborators
        case tasks
    }
}
