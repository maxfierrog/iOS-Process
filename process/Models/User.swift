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
    var authID: String
    var username: String
    var name: String
    var email: String
    var profilePictureID: String?
    
    // Functional user data
    var assignedTasks: Array<String>
    var ownedProjects: Array<Project>
    var invitedProjects: Array<Project>
    var receivedInvites: Array<Invite>
    
    enum CodingKeys: String, CodingKey {
        case authID
        case username
        case name
        case email
        case assignedTasks
        case profilePictureID
        case ownedProjects
        case invitedProjects
        case receivedInvites
    }
    
    /* MARK: Methods */
    
    /** Initializes a user data model from a screen NAME, a unique USERNAME,
     and a unique EMAIL. Used to save new user data during registration. */
    init(name: String, username: String, email: String) {
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
}
