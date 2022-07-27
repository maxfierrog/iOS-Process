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
    
    /* MARK: Project fields */
    
    var data: ProjectData
    var tasks: [Task] = []
    var owner: User = User()
    var collaborators: [User] = []
    
    /* MARK: Project methods */
    
    /* Initializers and protocol methods*/
    
    init(name: String, owner: User, description: String?) {
        self.data = ProjectData(name: name, owner: owner.data.id, description: description)
        self.owner = owner
    }
    
    init(data: ProjectData, owner: User) {
        self.data = data
        self.owner = owner
    }
    
    init() {
        self.data = ProjectData(name: "", owner: "", description: nil)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: Project, rhs: Project) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /* Builder pattern */

    func addCollaborators(users: [User]) -> Project {
        for user in users {
            self.data.collaborators.append(user.data.id)
            self.collaborators.append(user)
        }
        return self
    }
    
    func removeCollaborator(user: User) -> Project {
        self.data.collaborators.removeAll { $0 == user.data.id }
        self.collaborators.removeAll { $0.data.id == user.data.id }
        return self
    }
    
    func addTasks(_ tasks: [Task]) -> Project {
        for task in tasks {
            self.data.tasks.append(task.data.id)
            self.tasks.append(task)
        }
        return self
    }
    
    func removeTask(_ task: Task) -> Project {
        self.data.tasks.removeAll { $0 == task.data.id }
        self.tasks.removeAll { $0.data.id == task.data.id }
        return self
    }
    
    func complete() -> Project {
        self.data = ProjectData(copyOf: self.data, completionDate: Date())
        return self
    }
    
    func reopen() -> Project {
        self.data = ProjectData(copyOf: self.data, completionDate: nil)
        return self
    }
    
    /* Storage pull methods */
        
    func pullCollaborators(_ completion: (_ error: Error?, _ collaborators: [User]?) -> Void) {
        
    }
    
    func pullTasks(_ completion: (_ error: Error?, _ collaborators: [Task]?) -> Void) {
        
    }
    
    func pullOwner(_ completion: (_ error: Error?, _ owner: User?) -> Void) {
        
    }
    
    /* Storage push methods */
    
    func pushData(_ completion: @escaping(_ error: Error?) -> Void) {
        APIHandler.pushProjectData(self) { error in
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
        case description
        case dateCreated
        case dateCompleted
        case collaborators
        case tasks
    }
    
    /* MARK: Project data initializers */
    
    /** Used to generate a new unique project. */
    init(name: String, owner: String, description: String?) {
        self.name = name
        self.owner = owner
        self.description = description
        self.dateCreated = Date()
        self.dateCompleted = nil
        self.id = UUID().uuidString
        self.collaborators = []
        self.tasks = []
    }
    
    /** Allows for updating a Project object with ProjectData including a  new
     completion date. */
    init(copyOf: ProjectData, completionDate: Date?) {
        self.id = copyOf.id
        self.name = copyOf.name
        self.owner = copyOf.owner
        self.description = copyOf.description
        self.dateCreated = copyOf.dateCreated
        self.collaborators = copyOf.collaborators
        self.tasks = copyOf.tasks
        self.dateCompleted = completionDate
    }
}
