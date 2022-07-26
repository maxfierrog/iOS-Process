//
//  Invite.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import Foundation

public struct Invite: Codable {
    
    var id: String
    var sender: String
    var receiver: String
    var project: String
    var timeSent: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case receiver
        case project
        case timeSent
    }
}
