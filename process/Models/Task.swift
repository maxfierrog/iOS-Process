//
//  Task.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import Foundation

enum TaskSize: Int {
    case small = 1
    case medium = 2
    case big = 3
}

class Task: Hashable {
    
    var data: TaskData
    
    init(data: TaskData) {
        self.data = data
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: Task, rhs: Task) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

public struct TaskData: Codable {
    
    var id: String
    var name: String
    var size: Int
    var description: String?
    var dateCreated: String
    var dateDue: String
    var dateCompleted: String?
    var assignee: String?
    var creator: String
    var project: String
    var subtasks: Array<String>
    
    enum CodingKeys: String, CodingKey {
        case id
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
