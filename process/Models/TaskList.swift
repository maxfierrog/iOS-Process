//
//  TaskList.swift
//  process
//
//  Created by maxfierro on 7/25/22.
//


import Foundation


/** Types of task sorting orders available to users. */
enum Sort: String, CaseIterable, Identifiable {
    case creationDate
    case dueDate
    case size
    case topological
    case any
    var id: Self { self }
}


/** Utility collection class for facilitating common operatons on task
 collections such as sorting and insertion. */
class TaskCollection {
    
    /* MARK: Fields */
    
    var tasks: [TaskCollectionItem] = []
    
    /* MARK: Methods */
    
    init(_ taskIDList: [String]) {
        for taskID in taskIDList {
            self.tasks.append(TaskCollectionItem(taskID))
        }

    }
    
    func insertTask(_ taskID: String) {
        tasks.append(TaskCollectionItem(taskID))
    }
    
    func sort(_ sort: Sort?) {
        switch sort {
        case .creationDate:
            self.tasks = Array(self.tasks).sorted { i, j in
                return i.task.data.dateCreated > j.task.data.dateCreated // FIXME: Compare dates as strings
            }
        case .dueDate:
            self.tasks = Array(self.tasks).sorted { i, j in
                return i.task.data.dateDue > j.task.data.dateDue // FIXME: Compare dates as strings
            }
        case .size:
            self.tasks = Array(self.tasks).sorted { i, j in
                return i.task.data.size > j.task.data.size // FIXME: Might be the wrong way around
            }
        default:
            self.tasks = Array(self.tasks)
        }
    }
    
}


/** Helper class for the task collection, which facilitates downloading many
 tasks into a single TaskCollections in one go. */
class TaskCollectionItem: Hashable {
    
    var task: Task = Task(creatorID: "")
    
    init(_ taskID: String) {
        Task.pull(taskID) { task, error in
            guard error == nil else { return }
            self.task = task!
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: TaskCollectionItem, rhs: TaskCollectionItem) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}
