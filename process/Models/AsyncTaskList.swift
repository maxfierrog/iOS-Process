//
//  AsyncTaskList.swift
//  process
//
//  Created by maxfierro on 7/25/22.
//


import Foundation


/** Types of task sorting orders available to users. */
enum TaskSort: String, CaseIterable, Identifiable {
    case recentlyCreated
    case soonestDue
    case smallest
    case largest
    case topological
    case none
    var id: Self { self }
}


/** Utility collection class for facilitating common operatons on task
 collections such as sorting and insertion. */
class AsyncTaskList {
    
    /* MARK: Fields */
    
    var items: [TaskListItem] = []
    
    /* MARK: Methods */
    
    init(_ taskIDList: [String]) {
        for taskID in taskIDList {
            self.items.append(TaskListItem(taskID))
        }
    }
    
    func insertTask(_ taskID: String) {
        items.append(TaskListItem(taskID))
    }
    
    func sort(_ sort: TaskSort) {
        switch sort {
        case .recentlyCreated:
            self.items.sort { i, j in
                return i.task.data.dateCreated > j.task.data.dateCreated // FIXME: Compare dates as strings
            }
        case .soonestDue:
            self.items.sort { i, j in
                return i.task.data.dateDue > j.task.data.dateDue // FIXME: Compare dates as strings
            }
        case .smallest:
            self.items.sort { i, j in
                return i.task.data.size > j.task.data.size // FIXME: Might be the wrong way around
            }
        case .largest:
            self.items.sort { i, j in
                return i.task.data.size < j.task.data.size // FIXME: Might be the wrong way around
            }
        default:
            return
        }
    }
    
}


/** Helper class for the task collection, which facilitates downloading many
 tasks into a single TaskCollections in one go. */
class TaskListItem: Hashable {
    
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
    
    public static func ==(lhs: TaskListItem, rhs: TaskListItem) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}
