//
//  User.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import Foundation
import SwiftUI


/** Singleton class used as a functional intermediary between the UserData
 struct, which stores user data and models. */
class User: ObservableObject {
        
    var data: UserData
    var profilePicture: UIImage = UIImage(named: ProfileConstant.defaultProfilePicture)!
    var taskList: AsyncTaskList
    
    /* MARK: Initializers */
    
    init(_ data: UserData) {
        self.data = data
        self.taskList = AsyncTaskList(data.tasks)
    }
    
    init() {
        self.data = UserData()
        self.taskList = AsyncTaskList([])
    }
    
    /* MARK: Builder pattern */
    
    func finishEdit() { return }
    
    func refreshTaskList() -> User {
        self.taskList = AsyncTaskList(self.data.tasks)
        return self
    }
    
    func changeProfilePicture(_ image: UIImage) -> User {
        self.profilePicture = image
        return self
    }
    
    func changeName(_ name: String) -> User {
        self.data = UserData(copyOf: self.data,
                             name: name,
                             username: self.data.username,
                             email: self.data.email)
        return self
    }
    
    func changeUsername(_ username: String) -> User {
        self.data = UserData(copyOf: self.data,
                             name: self.data.name,
                             username: username,
                             email: self.data.email)
        return self
    }
    
    func changeEmail(_ email: String) -> User {
        self.data = UserData(copyOf: self.data,
                             name: self.data.name,
                             username: self.data.username,
                             email: email)
        return self
    }
    
    func addTask(_ taskID: String) -> User {
        if !self.data.tasks.contains(taskID) {
            self.data.tasks.append(taskID)
        }
        return self
    }
    
    func removeTask(_ taskID: String) -> User {
        self.data.tasks.removeAll { $0 == taskID }
        return self
    }
    
    func addOwnedProject(_ projectID: String) -> User {
        self.data.ownedProjects.append(projectID)
        self.data.allProjects.append(projectID)
        return self
    }
    
    func removeOwnedProject(_ projectID: String) -> User {
        self.data.ownedProjects.removeAll { $0 == projectID }
        self.data.allProjects.removeAll { $0 == projectID }
        return self
    }
    
    func addInvitedProject(_ projectID: String) -> User {
        self.data.invitedProjects.append(projectID)
        self.data.allProjects.append(projectID)
        return self
    }
    
    func removeInvitedProject(_ projectID: String) -> User {
        self.data.invitedProjects.removeAll { $0 == projectID }
        self.data.allProjects.removeAll { $0 == projectID }
        return self
    }
    
    func addInvite(_ inviteID: String) -> User {
        self.data.receivedInvites.append(inviteID)
        return self
    }
    
    func removeInvite(_ inviteID: String) -> User {
        self.data.receivedInvites.removeAll { $0 == inviteID }
        return self
    }
    
    /* MARK: Storage methods */
    
    func pull(_ id: String, _ completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        APIHandler.pullUser(id) { user, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(user, nil)
        }
    }
        
    func push(_ completion: @escaping(_ error: Error?) -> Void) {
        APIHandler.pushUser(self) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    func pullProfilePicture(_ completion: @escaping(_ error: Error?, _ image: UIImage?) -> Void) {
        APIHandler.pullProfilePicture(userID: self.data.id) { error, image in
            guard error == nil else {
                completion(error, nil)
                return
            }
            self.profilePicture = image!
            completion(nil, image)
        }
    }
    
    func pushProfilePicture(_ image: UIImage, _ completion: @escaping(_ error: Error?) -> Void) {
        let uploadTask = APIHandler.pushProfilePicture(image, userID: self.data.id) { error, _ in
            guard error == nil else {
                completion(error)
                return
            }
        }
        uploadTask.resume()
        completion(nil)
    }
}


/** User data model deconstructible and reconstructible by Firestore SDK
 methods. Stores non-critical private user invormation. */
public struct UserData: Codable {
    
    /* MARK: User data fields */
    
    // Identifying user data
    var id: String
    var authID: String
    var username: String
    var name: String
    var email: String
    
    // Functional user data
    var tasks: Array<String>
    var ownedProjects: Array<String>
    var invitedProjects: Array<String>
    var allProjects: Array<String>
    var receivedInvites: Array<String>
    
    enum CodingKeys: String, CodingKey {
        case id
        case authID
        case username
        case name
        case email
        case tasks
        case ownedProjects
        case allProjects
        case invitedProjects
        case receivedInvites
    }
    
    /* MARK: User data initializers */
    
    /** Initialize a placeholder user data model. */
    init() {
        
        // To be determined
        self.name = ""
        self.email = ""
        self.username = ""
        
        // User constants
        self.tasks = []
        self.ownedProjects = []
        self.allProjects = []
        self.invitedProjects = []
        self.receivedInvites = []
        self.id = UUID().uuidString
        do {
            try self.authID = APIHandler.currentUserAuthID()
        } catch APIHandlerError.noAuthenticatedUser {
            self.authID = UserConstant.noAuthenticatedUserAuthIDMessage
        } catch {
            self.authID = UserConstant.noAuthIDMessage
        }
    }
    
    /** Allows for creating a copy of a user's data, wtih additional or modfied
     fields. */
    init(copyOf: UserData, name: String, username: String, email: String) {
        
        // Modifiable fields
        self.name = name
        self.username = username
        self.email = email

        // User constants
        self.id = copyOf.id
        self.authID = copyOf.authID
        self.tasks = copyOf.tasks
        self.ownedProjects = copyOf.ownedProjects
        self.allProjects = copyOf.allProjects
        self.invitedProjects = copyOf.invitedProjects
        self.receivedInvites = copyOf.receivedInvites
    }
}
