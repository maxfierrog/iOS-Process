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
    
    /* MARK: User class fields */
    
    var data: UserData
    var profilePicture: UIImage = UIImage(named: ProfileConstant.defaultProfilePicture)!
    var assignedTasks: [Task] = []
    var ownedProjects: [Project] = []
    var invitedProjects: [Project] = []
    var receivedInvites: [Invite] = []
    
    /* MARK: User class methods */
    
    /* Initializers */
    
    init() {
        data = UserData()
    }
    
    init(name: String, username: String, email: String) {
        self.data = UserData(name: name, username: username, email: email)
    }
    
    init(_ data: UserData) {
        self.data = data
    }
    
    /* Builder pattern */
    
    func changeProfilePicture(_ image: UIImage) -> User {
        self.profilePicture = image
        return self
    }
    
    func changeUsername(_ username: String) -> User {
        self.data = UserData(copyOf: self.data, name: self.data.name, username: username)
        return self
    }
    
    func changeName(_ name: String) -> User {
        self.data = UserData(copyOf: self.data, name: name, username: self.data.username)
        return self
    }
    
    func addTasks(_ tasks: [Task]) -> User {
        for task in tasks {
            self.data.assignedTasks.append(task.data.id)
            self.assignedTasks.append(task)
        }
        return self
    }
    
    func removeTask(_ task: Task) -> User {
        self.data.assignedTasks.removeAll { $0 == task.data.id }
        self.assignedTasks.removeAll { $0.data.id == task.data.id }
        return self
    }
    
    func addOwnedProjects(_ projects: [Project]) -> User {
        for project in projects {
            self.data.ownedProjects.append(project.data.id)
            self.ownedProjects.append(project)
        }
        return self
    }
    
    func removeOwnedProject(_ project: Project) -> User {
        self.data.ownedProjects.removeAll { $0 == project.data.id }
        self.ownedProjects.removeAll { $0.data.id == project.data.id }
        return self
    }
    
    /* Storage pull methods */

    func pullProfilePicture(_ completion: @escaping(_ error: Error?, _ image: UIImage?) -> Void) {
        APIHandler.pullProfilePicture(user: self) { error, image in
            guard error == nil else {
                completion(error, nil)
                return
            }
            self.profilePicture = image!
            completion(nil, image)
        }
    }
    
    /* Storage push methods */
    
    func pushData(_ completion: @escaping(_ error: Error?) -> Void) {
        APIHandler.pushUserData(self) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    func pushProfilePicture(_ image: UIImage, _ completion: @escaping(_ error: Error?) -> Void) {
        let uploadTask = APIHandler.pushProfilePicture(image, user: self) { error, _ in
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
    var assignedTasks: Array<String>
    var ownedProjects: Array<String>
    var invitedProjects: Array<String>
    var receivedInvites: Array<String>
    
    enum CodingKeys: String, CodingKey {
        case id
        case authID
        case username
        case name
        case email
        case assignedTasks
        case ownedProjects
        case invitedProjects
        case receivedInvites
    }
    
    /* MARK: User data initializers */
    
    /** Initializes a user data model from a screen NAME, a unique USERNAME,
     and a unique EMAIL. Used to save new user data during registration. */
    init(name: String, username: String, email: String) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.username = username
        self.assignedTasks = []
        self.ownedProjects = []
        self.invitedProjects = []
        self.receivedInvites = []
        do {
            try self.authID = APIHandler.currentUserAuthID()
        } catch APIHandlerError.noAuthenticatedUser {
            self.authID = UserConstant.noAuthenticatedUserAuthIDMessage
        } catch {
            self.authID = UserConstant.noAuthIDMessage
        }
    }
    
    /** Initializes a COPYOF a user data model, with updates to their screen
     NAME and USERNAME. */
    init(copyOf: UserData, name: String, username: String) {
        self.name = name
        self.username = username
        self.id = copyOf.id
        self.email = copyOf.email
        self.authID = copyOf.authID
        self.assignedTasks = copyOf.assignedTasks
        self.ownedProjects = copyOf.ownedProjects
        self.invitedProjects = copyOf.invitedProjects
        self.receivedInvites = copyOf.receivedInvites
    }
    
    /** Initialize a placeholder user data model. */
    init() {
        self.name = ""
        self.email = ""
        self.username = ""
        self.authID = ""
        self.id = ""
        self.assignedTasks = []
        self.ownedProjects = []
        self.invitedProjects = []
        self.receivedInvites = []
    }
}
