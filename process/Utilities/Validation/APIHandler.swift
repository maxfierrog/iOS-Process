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
    
    static func isUniqueUsername(_ username: String,
                                 _ completion: @escaping(_ querySnapshot: QuerySnapshot?, _ error: Error?) -> ()) {
        let usersCollection = Firestore.firestore().collection("users")
        let query = usersCollection.whereField("username", isEqualTo: username)
        query.getDocuments { querySnapshot, error in
            completion(querySnapshot, error)
        }
    }
}
