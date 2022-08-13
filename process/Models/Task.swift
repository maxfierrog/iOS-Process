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

class Task: Hashable, Identifiable {
    
    var data: TaskData
    var subtaskList: AsyncTaskList = AsyncTaskList([])
    
    /* MARK: Initializers */
    
    init(_ data: TaskData) {
        self.data = data
    }
    
    init (creatorID: String) {
        self.data = TaskData(creatorID: creatorID)
        self.subtaskList = AsyncTaskList([])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: Task, rhs: Task) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /* MARK: Builder pattern */
    
    func finishEdit() { return }
    
//    func refreshTaskList() -> Task {
//        self.subtaskList = AsyncTaskList(self.data.subtasks)
//        return self
//    }
    
    func changeName(_ name: String) -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: name,
                             size: self.data.size,
                             description: self.data.description,
                             dateDue: self.data.dateDue,
                             assignee: self.data.assignee,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: self.data.dateCompleted)
        return self
    }
    
    func changeSize(_ size: Int) -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: size,
                             description: self.data.description,
                             dateDue: self.data.dateDue,
                             assignee: self.data.assignee,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: self.data.dateCompleted)
        return self
    }
    
    func changeDescription(_ description: String?) -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: self.data.size,
                             description: description,
                             dateDue: self.data.dateDue,
                             assignee: self.data.assignee,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: self.data.dateCompleted)
        return self
    }
    
    func changeDateDue(_ date: Date) -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: self.data.size,
                             description: self.data.description,
                             dateDue: date,
                             assignee: self.data.assignee,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: self.data.dateCompleted)
        return self
    }
    
    func changeAssignee(_ assigneeID: String?) -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: self.data.size,
                             description: self.data.description,
                             dateDue: self.data.dateDue,
                             assignee: assigneeID,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: self.data.dateCompleted)
        return self
    }
    
    func changeProject(_ projectID: String?) -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: self.data.size,
                             description: self.data.description,
                             dateDue: self.data.dateDue,
                             assignee: self.data.assignee,
                             project: projectID,
                             subtasks: self.data.subtasks,
                             dateCompleted: self.data.dateCompleted)
        return self
    }
    
    func addSubtask(_ task: Task) -> Task {
        self.subtaskList.tasks.append(task)
        self.data.subtasks.append(task.data.id)
        return self
    }
    
    func removeSubtask(_ taskID: String) -> Task {
        self.data.subtasks.removeAll { $0 == taskID }
        return self
    }
    
    func complete() -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: self.data.size,
                             description: self.data.description,
                             dateDue: self.data.dateDue,
                             assignee: self.data.assignee,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: Date())
        return self
    }
    
    func reopen() -> Task {
        self.data = TaskData(copyOf: self.data,
                             name: self.data.name,
                             size: self.data.size,
                             description: self.data.description,
                             dateDue: self.data.dateDue,
                             assignee: self.data.assignee,
                             project: self.data.project,
                             subtasks: self.data.subtasks,
                             dateCompleted: nil)
        return self
    }
    
    /* MARK: Storage methods */
    
    func push(_ completion: @escaping(_ error: Error?) -> Void) {
        APIHandler.pushTask(self) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
        
    static func pull(_ id: String, _ completion: @escaping(_ task: Task?, _ error: Error?) -> Void) {
        APIHandler.pullTask(taskID: id) { task, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(task, nil)
        }
    }
    
    func delete(_ completion: @escaping(_ error: Error?) -> Void) {
        APIHandler.deleteTask(self) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
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
    init(creatorID: String) {
        
        // To be determined
        self.name = ""
        self.size = TaskSize.small.rawValue
        self.description = nil
        self.dateDue = Date()
        self.assignee = nil
        self.project = nil
        self.subtasks = []
        self.dateCompleted = nil
        
        // Task constants
        self.id = UUID().uuidString
        self.creator = creatorID
        self.dateCreated = Date()
    }
    
    /** Allows for updating a Task object's data.  */
    init(copyOf: TaskData,
         name: String,
         size: Int,
         description: String?,
         dateDue: Date,
         assignee: String?,
         project: String?,
         subtasks: [String],
         dateCompleted: Date?) {
        
        // Modifiable fields
        self.name = name
        self.size = size
        self.description = description
        self.dateDue = dateDue
        self.assignee = assignee
        self.project = project
        self.dateCompleted = dateCompleted
        self.subtasks = subtasks

        // Task constants
        self.creator = copyOf.creator
        self.id = copyOf.id
        self.dateCreated = copyOf.dateCreated
    }
}
