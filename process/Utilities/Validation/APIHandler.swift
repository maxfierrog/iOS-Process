//
//  APIHandler.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class APIHandler {
    
    /* Firebase Firestore */
    
    static func uploadNewUser(_ user: User, _ completion: @escaping(_ error: Error?) -> ()) {
        Firestore.firestore().collection("users").document(user.id).setData(user.attributes) { err in
            completion(err)
        }
    }
}
