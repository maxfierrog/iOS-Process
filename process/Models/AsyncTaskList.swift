//
//  AsyncTaskList.swift
//  process
//
//  Created by maxfierro on 7/25/22.
//


import Foundation


/** The models for views which contain clickable lists of tasks must conform
 to this protocol. */
protocol TaskListParent {
    
    // The current user
    var user: User { get set }
    
    // The tasks which this list will display
    var taskList: AsyncTaskList { get set }
    
    // Should know which task was clicked on within the list
    var selectedTask: Task { get set }
    
    // Should be able to refresh the task list for changes
    func refreshTaskList() -> Void
    
    // Should have an action happen when a task is chosen
    func tappedTask() -> Void
    
    // Should be able to dismiss an edit/new task screen (cancel button)
    func dismissChildView(_ named: String) -> Void
    
    // Should be able to communicate events in children views through banners
    func showBannerWithSuccessMessage(_ message: String?) -> Void
}


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
class AsyncTaskList: ObservableObject {
    
    /* MARK: Fields */
    
//    @Published var items: [TaskListItem] = []
    
    @Published var allTasks: [Task] = []
    @Published var tasks: [Task] = []
    @Published var taskDict: [String: Task] = [:]
    
    // Adjacency dictionary mapping taskIDs to a list of subtask IDs
    var digraph: [String : [String]] = [:]
    
    /* MARK: Methods */
    
//    init(_ taskIDList: [String]) {
//        for taskID in taskIDList {
//            self.items.append(TaskListItem(taskID))
//        }
//    }
    
    init(_ taskList: [Task]) {
        for task in taskList {
            self.insertTask(task)
        }
    }
    
//    func insertTask(_ taskID: String) {
//        items.append(TaskListItem(taskID))
//    }
    
    func insertTask(_ task: Task) {
        tasks.append(task)
        allTasks.append(task)
        self.taskDict[task.data.id] = task
    }
    
    func removeTask(_ taskID: String) {
        self.taskDict.removeValue(forKey: taskID)
        self.tasks.removeAll { task in
            return task.data.id == taskID
        }
        self.allTasks.removeAll { task in
            return task.data.id == taskID
        }
    }
    
    func sort(_ sort: TaskSort) {
        switch sort {
        case .recentlyCreated:
            self.tasks.sort { i, j in
                return i.data.dateCreated > j.data.dateCreated // FIXME: Compare dates as strings
            }
        case .soonestDue:
            self.tasks.sort { i, j in
                return i.data.dateDue > j.data.dateDue // FIXME: Compare dates as strings
            }
        case .smallest:
            self.tasks.sort { i, j in
                return i.data.size > j.data.size // FIXME: Might be the wrong way around
            }
        case .largest:
            self.tasks.sort { i, j in
                return i.data.size < j.data.size // FIXME: Might be the wrong way around
            }
        default:
            return
        }
    }
    
    func getDoneTasks() {
        self.tasks = self.allTasks.filter { task in
            return task.data.dateCompleted != nil
        }
    }
    
    func getUnfinishedTasks() {
        self.tasks = self.allTasks.filter { task in
            return task.data.dateCompleted == nil
        }
    }
    
    /* MARK: Task graph algorithms */
    
    /** Non-destructively returns another instance of AsyncTaskList containing
     only tasks which TASK can have as a subtask while avoiding cyclic behavior
     in the task graph. */
    func getSubtaskOptions(task: Task) -> AsyncTaskList {
        
        // Preprocessing, ensure changes since last sort are considered
        self.initializeGraph()
        self.populateTaskGraph()
        
        // Graph of tasks and its transpose
        let graph = self.digraph
        let transpose = self.getGraphTranspose()
        
        // Set of all tasks, and the set of task not available as subtasks
        var taskSet = Set(graph.keys)
        var upstreamTaskSet: Set<String> = []
        let directSubtasks: Set<String> = Set(self.digraph[task.data.id]!)
        
        // Tasks which are 'upstream' of TASK, which cannot be its subtasks
        upstreamTaskSet = Set(self.preorderTraversal(dict: transpose, fromNode: task.data.id))
        
        // The relative complement of all tasks with those 'upstream' and those
        // which are already subtasks
        taskSet.subtract(upstreamTaskSet)
        taskSet.subtract(directSubtasks)
        
        return AsyncTaskList(getTaskFromIDs(Array(taskSet)))
    }
    
    
    /** Non-destructively sorts the current tasks in a possible order of completion
     by taking into consideration that subtasks must get completed before their
     tasks. Returns an AsyncTaskList with the specified ordering, and returns
     self when there is a cycle as to not disrupt user experience.
        
     Where V and E are the count of vertices and edges, the time complexity is
     in O(V + E). */
    func getTopologicalOrdering() {
        
        // Preprocessing, ensure changes since last sort are considered
        self.initializeGraph()
        self.populateTaskGraph()
        
        // Let the indegree of a node be the amount of edges coming into it
        var indegrees = self.getDigraphIndigrees()
        var zeroIndegreeNodes = self.getZeroIndegreeNodes(indegrees: indegrees)
        var topologicalOrdering: [String] = []
        
        // Sort
        while zeroIndegreeNodes.count > 0 {
            let node = zeroIndegreeNodes.popLast()!
            topologicalOrdering.append(node)
            for child in self.digraph[node]! {
                indegrees[child]! -= 1
                if indegrees[child]! == 0 {
                    zeroIndegreeNodes.append(child)
                }
            }
        }
        
        // Verify there are no edges left, implying no cycles
        if topologicalOrdering.count == self.digraph.keys.count {
            self.tasks = getTaskFromIDs(topologicalOrdering.reversed())
        } else {
            return
        }
    }
    
    /* MARK: Graph helper methods */
    
    /** Returns a list of nodes with no incoming edges, or whose indegree
     assignment is zero. */
    private func getZeroIndegreeNodes(indegrees: [String: Int]) -> [String] {
        var result: [String] = []
        for node in indegrees.keys {
            if indegrees[node] == 0 {
                result.append(node)
            }
        }
        return result
    }
    
    /** Returns a dictionary mapping nodes to the amount of edges which are
     directed at them (mapping tasks to the amount of tasks they are a subtask
     of). */
    private func getDigraphIndigrees() -> [String: Int] {
        var indegree: [String: Int] = [:]
        for task in self.tasks {
            indegree[task.data.id] = 0
        }
        for task in self.tasks {
            for subtask in task.data.subtasks {
                indegree[subtask]! += 1
            }
        }
        return indegree
    }
    
    /** Returns all nodes visited from a preorder traversal of DICT starting
     at FROMNODE, recursively. */
    private func preorderTraversal(dict: [String: [String]], fromNode: String) -> [String] {
        if !dict.keys.contains(fromNode) { return [] }
        var result: [String] = []
        result.append(fromNode)
        for child in dict[fromNode]! {
            result.append(contentsOf: preorderTraversal(dict: dict, fromNode: child))
        }
        return result
    }
    
    /** Returns the transpose of the current task graph, or in other words, the
     task graph with all edges facing the opposite way. */
    private func getGraphTranspose() -> [String : [String]] {
        var result: [String : [String]] = [:]
        for task in self.digraph.keys {
            result[task] = []
        }
        for task in self.digraph.keys {
            for subtask in self.digraph[task]! {
                result[subtask]?.append(task)
            }
        }
        return result
    }
    
    // Quadratic, but only runs once
    private func populateTaskGraph() {
        for task in self.tasks {
            for subtask in task.data.subtasks {
                self.addEdge(from: task.data.id, to: subtask)
            }
        }
    }
    
    // Linear, only runs once
    private func initializeGraph() {
        self.digraph = [:]
        for task in self.tasks {
            digraph[task.data.id] = []
        }
    }
    
    // Constant time
    private func addEdge(from: String, to: String) {
        digraph[from]?.append(to)
    }
    
    private func getTaskFromIDs(_ ids: [String]) -> [Task] {
        var result: [Task] = []
        for item in ids {
            result.append(taskDict[item]!)
        }
        return result
    }
}


/** Helper class for the task collection, which facilitates downloading many
 tasks into a single TaskCollections in one go. */
//class TaskListItem: ObservableObject, Hashable, Identifiable {
//
//    @Published var task: Task = Task(creatorID: "")
//
//    init(_ taskID: String) {
//        Task.pull(taskID) { task, error in
//            guard error == nil else { return }
//            self.task = task!
//        }
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(ObjectIdentifier(self))
//    }
//
//    public static func ==(lhs: TaskListItem, rhs: TaskListItem) -> Bool {
//        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
//    }
//
//    func getID() -> String {
//        return self.task.data.id
//    }
//
//    func getSubtasks() -> [String] {
//        return self.task.data.subtasks
//    }
//
//}
