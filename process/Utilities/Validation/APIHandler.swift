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
    
    static private let db = Firestore.firestore()
    
    static private let usersCollection = db.collection("users")
    static private let invitesCollection = db.collection("invites")
    static private let projectsCollection = db.collection("projects")
    static private let tasksCollection = db.collection("tasks")
    static private let utilsCollection = db.collection("utils")

    static func uploadNewUser(_ user: User, _ completion: @escaping(_ error: Error?) -> ()) {
        do {
            try db.collection("users").document(UUID().uuidString).setData(from: user)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    static func matchUsernameQuery(_ username: String, _ completion: @escaping(_ querySnapshot: QuerySnapshot?) -> Void) {
        let query = usersCollection.whereField("username", isEqualTo: username)
        query.getDocuments { querySnapshot, error in
            if (error != nil) {
                print(error?.localizedDescription) // debug
            } else {
                completion(querySnapshot)
            }
        }
    }
    
    static func currentUserAuthID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    static func getUsernameRepeatCount(_ completion: @escaping(_ count: Int) -> Void) {
        let usernameCounterDocument = utilsCollection.document("username-counter")
        usernameCounterDocument.getDocument { document, error in
            if let document = document, document.exists {
                completion(document.data()!["counter"] as! Int)
            } else {
                print("Document does not exist") // debug
            }
        }
    }
    
    static func incrementUsernameRepeatCount() -> Void {
        utilsCollection.document("username-counter").updateData([
            "counter": FieldValue.increment(Int64(1))
        ])
    }
    
    static func getUserFromEmail(_ email: String, _ completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        let userQuery = usersCollection.whereField("email", isEqualTo: email)
        userQuery.getDocuments { querySnapshot, error in
            if (error == nil && !querySnapshot!.documents.isEmpty) {
                let userDocumentID = querySnapshot!.documents[0].documentID
                let docRef = db.collection("users").document(userDocumentID)
                docRef.getDocument(as: User.self) { result in
                    switch result {
                    case .success(let user):
                        completion(user, nil)
                    case .failure(let error):
                        print(error.localizedDescription) // debug
                        completion(nil, error)
                    }
                }
            } else if (error != nil) {
                print(error!.localizedDescription) // debug
                completion(nil, error)
            }
        }
    }
    
}
