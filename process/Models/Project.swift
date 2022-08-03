//
//  Project.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import Foundation


/** Intermediary class for performing operations on projects. Can be seen as a
 singleton class for every relevant project. */
class Project: Hashable {
        
    var data: ProjectData
    var taskList: AsyncTaskList
        
    /* MARK: Initializers */
    
    init(_ data: ProjectData) {
        self.data = data
        self.taskList = AsyncTaskList(data.tasks)
    }
    
    init(creatorID: String) {
        self.data = ProjectData(creatorID: creatorID)
        self.taskList = AsyncTaskList([])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: Project, rhs: Project) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /* MARK: Builder pattern */
    
    func finishEdit() { return }
    
    func refreshTaskList() -> Project {
        self.taskList = AsyncTaskList(self.data.tasks)
        return self
    }
    
    func changeName(_ name: String) -> Project {
        self.data = ProjectData(copyOf: self.data,
                                name: name,
                                owner: self.data.owner,
                                description: self.data.description,
                                completionDate: self.data.dateCompleted)
        return self
    }
    
    func changeOwner(_ userID: String) -> Project {
        self.data = ProjectData(copyOf: self.data,
                                name: self.data.name,
                                owner: userID,
                                description: self.data.description,
                                completionDate: self.data.dateCompleted)
        return self
    }
    
    func changeDescription(_ description: String) -> Project {
        self.data = ProjectData(copyOf: self.data,
                                name: self.data.name,
                                owner: self.data.owner,
                                description: description,
                                completionDate: self.data.dateCompleted)
        return self
    }
    
    func complete() -> Project {
        self.data = ProjectData(copyOf: self.data,
                                name: self.data.name,
                                owner: self.data.owner,
                                description: self.data.description,
                                completionDate: Date())
        return self
    }
    
    func reopen() -> Project {
        self.data = ProjectData(copyOf: self.data,
                                name: self.data.name,
                                owner: self.data.owner,
                                description: self.data.description,
                                completionDate: nil)
        return self
    }

    func addCollaborator(_ userID: String) -> Project {
        if !self.data.collaborators.contains(userID) {
            self.data.collaborators.append(userID)
        }
        return self
    }
    
    func removeCollaborator(_ userID: String) -> Project {
        self.data.collaborators.removeAll { $0 == userID }
        return self
    }
    
    func addTask(_ taskID: String) -> Project {
        if !self.data.tasks.contains(taskID) {
            self.data.tasks.append(taskID)
        }
        return self
    }
    
    func removeTask(_ taskID: String) -> Project {
        self.data.tasks.removeAll { $0 == taskID }
        return self
    }
    
    /* MARK: Storage methods */
        
    static func pull(_ id: String, _ completion: @escaping(_ project: Project?, _ error: Error?) -> Void) {
        APIHandler.pullProject(projectID: id) { project, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(project, nil)
        }
    }
    
    func push(_ completion: @escaping(_ error: Error?) -> Void) {
        APIHandler.pushProject(self) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
}


/** Project  data model deconstructible and reconstructible by Firestore SDK
 methods. Stores project attributes. */
public struct ProjectData: Codable {
    
    /* MARK: Project data fields */
    
    // Identifying data
    var id: String
    var name: String
    var owner: String
    var creator: String
    var description: String?
    var dateCreated: Date
    var dateCompleted: Date?
    
    // Productivity
    var collaborators: [String]
    var tasks: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case creator
        case description
        case dateCreated
        case dateCompleted
        case collaborators
        case tasks
    }
    
    /* MARK: Project data initializers */
    
    /** Used to generate placeholder Project data. */
    init(creatorID: String) {
        
        // To be determined
        self.name = ""
        self.owner = ""
        self.dateCompleted = nil
        self.description = nil
        
        // Project constants
        self.creator = creatorID
        self.dateCreated = Date()
        self.id = UUID().uuidString
        self.collaborators = []
        self.tasks = []
    }
    
    /** Allows for updating a Project object with ProjectData including a  new
     and updated fields. */
    init(copyOf: ProjectData, name: String, owner: String, description: String?, completionDate: Date?) {
        
        // Modifiable fields
        self.name = name
        self.owner = owner
        self.description = description
        self.dateCompleted = completionDate
        
        // Project contants
        self.id = copyOf.id
        self.creator = copyOf.creator
        self.collaborators = copyOf.collaborators
        self.tasks = copyOf.tasks
        self.dateCreated = copyOf.dateCreated
    }
}
