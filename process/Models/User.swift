//
//  User.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import Foundation


/** User data model deconstructible and reconstructible by Firestore SDK
 methods. Stores non-critical private user invormation. */
public struct User: Codable {
    
    /* MARK: User data fields */
    
    // Identifying user data
    var id: String
    var authID: String
    var username: String
    var name: String
    var email: String
    
    // Functional user data
    var assignedTasks: Array<String>
    var ownedProjects: Array<Project>
    var invitedProjects: Array<Project>
    var receivedInvites: Array<Invite>
    
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
    
    /* MARK: Methods */
    
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
    init(copyOf: User, name: String, username: String) {
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
