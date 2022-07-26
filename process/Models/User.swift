//
//  User.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import Foundation
import SwiftUI


/** User class used as functional intermediary between the User struct, which
 stores data, and internal models. */
class User: ObservableObject {
    
    /* MARK: User class fields */
    
    var data: UserData
    var image: UIImage = UIImage(named: ProfileConstant.defaultProfilePicture)!
    var tasks: TaskCollection = TaskCollection()
    var projects: [Project] = []
    
    /* MARK: User initializers */
    
    init() {
        data = UserData()
    }
    
    init(name: String, username: String, email: String) {
        self.data = UserData(name: name, username: username, email: email)
    }
    
    init(_ data: UserData) {
        self.data = data
    }
    
    /* MARK: User methods */
    
    func updateData(name: String, username: String, picture: UIImage, _ completion: @escaping(_ error: Error?) -> Void) {
        self.data = UserData(copyOf: self.data, name: name, username: username)
        self.image = picture
        APIHandler.uploadUser(self) { error in
            guard error == nil else {
                completion(error)
                return
            }
            self.updateProfilePicture(picture) { error in
                guard error == nil else {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func getProfilePicture(_ completion: @escaping(_ error: Error?, _ image: UIImage?) -> Void) {
        APIHandler.fetchImageFromStorage(user: self.data) { error, image in
            guard error == nil else {
                completion(error, nil)
                return
            }
            self.image = image!
            completion(nil, image)
        }
    }
        
    func updateProfilePicture(_ image: UIImage, _ completion: @escaping(_ error: Error?) -> Void) {
        let uploadTask = APIHandler.uploadImageToStorage(image: image, user: self.data) { error, _ in
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
