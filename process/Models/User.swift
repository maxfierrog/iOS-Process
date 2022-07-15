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
    var screenName: String
    var profilePictureID: String?
    
    var assignedTasks: Array<String>
    var ownedProjects: Array<Project>
    var invitedProjects: Array<Project>
    var receivedInvites: Array<Invite>
    
    enum CodingKeys: String, CodingKey {
        case authID
        case username
        case screenName
        case assignedTasks
        case profilePictureID
        case ownedProjects
        case invitedProjects
        case receivedInvites
    }
}

extension User {
    init(username: String, screenName: String) {
        self.authID = APIHandler.currentUserAuthID()
        self.username = username
        self.screenName = screenName
        self.assignedTasks = []
        self.ownedProjects = []
        self.invitedProjects = []
        self.receivedInvites = []
    }
}
