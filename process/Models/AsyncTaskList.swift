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
class AsyncTaskList {
    
    /* MARK: Fields */
    
    var items: [TaskListItem] = []
    
    // Adjacency dictionary mapping taskIDs to a list of subtask IDs
    var digraph: [String : [String]] = [:]
    
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
        
        // Tasks which are 'upstream' of TASK, which cannot be its subtasks
        upstreamTaskSet = Set(self.preorderTraversal(dict: transpose, fromNode: task.data.id))
        
        // The relative complement of all tasks with those 'upstream'
        taskSet.subtract(upstreamTaskSet)
        
        return AsyncTaskList(Array(taskSet))
    }
    
    
    /** Non-destructively sorts the current tasks in a possible order of completion
     by taking into consideration that subtasks must get completed before their
     tasks. Returns an AsyncTaskList with the specified ordering, and returns
     self when there is a cycle as to not disrupt user experience.
        
     Where V and E are the count of vertices and edges, the time complexity is
     in O(V + E). */
    func getTopologicalOrdering() -> AsyncTaskList {
        
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
            return AsyncTaskList(topologicalOrdering)
        } else {
            return self
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
        for task in self.items {
            indegree[task.getID()] = 0
        }
        for task in self.items {
            for subtask in task.getSubtasks() {
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
        for item in self.items {
            for subtask in item.getSubtasks() {
                self.addEdge(from: item.getID(), to: subtask)
            }
        }
    }
    
    // Linear, only runs once
    private func initializeGraph() {
        self.digraph = [:]
        for item in self.items {
            digraph[item.getID()] = []
        }
    }
    
    // Constant time
    private func addEdge(from: String, to: String) {
        digraph[from]?.append(to)
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
    
    func getID() -> String {
        return self.task.data.id
    }
    
    func getSubtasks() -> [String] {
        return self.task.data.subtasks
    }
    
}
