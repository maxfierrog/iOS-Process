//
//  Invite.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import Foundation

public struct Invite: Codable {
    
    var sender: UserData
    var receiver: UserData
    var project: Project
    var timeSent: String
    
    enum CodingKeys: String, CodingKey {
        case sender
        case receiver
        case project
        case timeSent
    }
}
