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
    
    /* MARK: Task fields */
    
    var data: TaskData
    var assignee: User?
    var subtasks: [Task] = []
    
    /* MARK: Task methods */
    
    /* Initializer and protocol methods */
    
    init(data: TaskData) {
        self.data = data
    }
    
    init(data: TaskData, assignee: User?) {
        self.data = data
        self.assignee = assignee
    }
    
    init(name: String,
         size: TaskSize,
         description: String?,
         dateDue: Date,
         assignee: User?,
         creator: String,
         project: String?) {
        self.data = TaskData(name: name,
                             size: size,
                             description: description,
                             dateDue: dateDue,
                             assignee: assignee == nil ? nil : assignee!.data.id,
                             creator: creator,
                             project: project)
        self.assignee = assignee
    }
    
    init () {
        self.data = TaskData()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: Task, rhs: Task) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /* Builder pattern */
    
}

public struct TaskData: Codable {
    
    /* MARK: Task data fields */
    
    var id: String
    var name: String
    var size: Int
    var description: String?
    var dateCreated: Date
    var dateDue: Date
    var dateCompleted: Date?
    var assignee: String?
    var creator: String
    var project: String?
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
    
    /* MARK: Task data initializers */
    
    /** Initializes placeholder task data. */
    init() {
        let placeholderUser = User()
        self.id = UUID().uuidString
        self.name = ""
        self.size = TaskSize.small.rawValue
        self.description = ""
        self.dateCreated = Date()
        self.dateDue = Date()
        self.dateCompleted = nil
        self.assignee = placeholderUser.data.id
        self.creator = placeholderUser.data.id
        self.project = nil
        self.subtasks = []
    }
    
    /** Allows for generating a copy of COPYOF, but with added subtasks. */
    init(copyOf: TaskData,
         subtasks: [String]) {
        
        // Modified field
        self.subtasks = subtasks
        
        // Copied fields
        self.name = copyOf.name
        self.size = copyOf.size
        self.description = copyOf.description
        self.dateDue = copyOf.dateDue
        self.dateCompleted = copyOf.dateCompleted
        self.assignee = copyOf.assignee
        self.creator = copyOf.creator
        self.project = copyOf.project

        // Task constants
        self.id = UUID().uuidString
        self.dateCreated = Date()
    }
    
    /** Allows for generating a copy of COPYOF, but with a completion date. */
    init(copyOf: TaskData,
         dateCompleted: Date) {
        
        // Modified field
        self.dateCompleted = dateCompleted

        // Copied fields
        self.name = copyOf.name
        self.size = copyOf.size
        self.description = copyOf.description
        self.dateDue = copyOf.dateDue
        self.assignee = copyOf.assignee
        self.creator = copyOf.creator
        self.project = copyOf.project
        self.subtasks = copyOf.subtasks


        // Task constants
        self.id = UUID().uuidString
        self.dateCreated = Date()
    }
    
    /** Allows for generating a copy of COPYOF with modified attributes. */
    init(copyOf: TaskData,
         size: TaskSize,
         description: String?,
         dateDue: Date,
         assignee: String?) {
        
        // Modified fields
        self.size = size.rawValue
        self.description = description
        self.dateDue = dateDue
        self.assignee = assignee
        
        // Copied fields
        self.name = copyOf.name
        self.creator = copyOf.creator
        self.project = copyOf.project
        self.subtasks = copyOf.subtasks
        self.dateCompleted = copyOf.dateCompleted


        // Task constants
        self.id = UUID().uuidString
        self.dateCreated = Date()
    }
    
    /** Allows the instantiation of a new task, taking only the parameters
     necessary for new task creation. */
    init(name: String,
         size: TaskSize,
         description: String?,
         dateDue: Date,
         assignee: String?,
         creator: String,
         project: String?) {
        
        // New task fields
        self.name = name
        self.size = size.rawValue
        self.description = description
        self.dateDue = dateDue
        self.assignee = assignee
        self.creator = creator
        self.project = project
        
        // To be determined
        self.dateCompleted = nil
        self.subtasks = []

        // Task constants
        self.id = UUID().uuidString
        self.dateCreated = Date()
    }
}
