//
//  User.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import Foundation

public struct User: Codable {
    
    var authID: String
    var username: String
    var name: String
    var email: String
    var profilePictureID: String?
    
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
}

extension User {
    init(name: String, username: String, email: String) {
        self.name = name
        self.email = email
        self.username = username
        self.authID = APIHandler.currentUserAuthID()
        self.assignedTasks = []
        self.ownedProjects = []
        self.invitedProjects = []
        self.receivedInvites = []
    }
}
