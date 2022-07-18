//
//  APIHandler.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class APIHandler {
    
    /* User requests */
    
    static func uploadNewUser(_ user: User, _ completion: @escaping(_ error: Error?) -> ()) {
        do {
            try Firestore.firestore().collection("users").document(UUID().uuidString).setData(from: user)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    static func matchUsernameQuery(_ username: String, _ completion: @escaping(_ querySnapshot: QuerySnapshot?) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        let query = usersCollection.whereField("username", isEqualTo: username)
        query.getDocuments { querySnapshot, error in
            if (error != nil) {
                print(error?.localizedDescription) // debugging
            } else {
                completion(querySnapshot)
            }
        }
    }
    
    static func currentUserAuthID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
}
