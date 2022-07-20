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


/** Helper class for API networking. The third party services used include:
 1. Realtime Database, via Firebase Firestore
 2. Storage Database, via Firebase Storage
 3. Authentication/Credentials, via Firebase Authentication
 4. Analytics, via Google Analytics
 5. Task exporting via Google Tasks API */
class APIHandler {
    
    /* MARK: Firestore database and collection references */
    
    static private let db = Firestore.firestore()
    static private let usersCollection = db.collection("users")
    static private let invitesCollection = db.collection("invites")
    static private let projectsCollection = db.collection("projects")
    static private let tasksCollection = db.collection("tasks")
    static private let utilsCollection = db.collection("utils")
    
    /* MARK: Login and registration helper methods */

    /** Uploads a new User struct model USER to Firestore. Allows for a
     COMPLETION block with an ERROR parameter, which will be nil if the upload
     was successful. */
    static func uploadNewUser(_ user: User, _ completion: @escaping(_ error: Error?) -> Void) {
        do {
            try db.collection("users").document(UUID().uuidString).setData(from: user)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    /** Allows for a COMPLETION block with a QUERYSNAPSHOT parameter. This will
     contain all documents whose 'username' field match USERNAME. If it errors
     while running the query the completion block is only passed the error. */
    static func matchUsernameQuery(_ username: String, _ completion: @escaping(_ querySnapshot: QuerySnapshot?, _ error: Error?) -> Void) {
        let query = usersCollection.whereField("username", isEqualTo: username)
        query.getDocuments { querySnapshot, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(querySnapshot, nil)
        }
    }
    
    /** Returns the Firebase Authentication service ID of the current user.
     Throws noAuthenticatedUser error if  there is no user authenticated. */
    static func currentUserAuthID() throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIHandlerError.noAuthenticatedUser("No user is currently authenticated.")
        }
        return user.uid
    }
    
    /** Pulls the COUNT of times someone has registered with an existing
     username from the 'utils' collection in Firestore. Allows for a COMPLETION
     block with the count and ERROR parameters, one of which must be nil. */
    static func getUsernameRepeatCount(_ completion: @escaping(_ count: Int?, _ error: Error?) -> Void) {
        let usernameCounterDocument = utilsCollection.document("username-counter")
        usernameCounterDocument.getDocument { document, error in
            if (error != nil) {
                completion(nil, error)
            } else if let document = document, document.exists {
                completion(document.data()!["counter"] as? Int, nil)
            } else {
                completion(nil, APIHandlerError.noUsernameRepeatDocument("No 'username-counter' document found."))
            }
        }
    }
    
    /** Increments the amount of times users have tried to register with an
     existing username by one in the 'utils' collection in Firestore. The use
     of the _increment()_ method only allows for one increase per second
     across all app clients. */
    static func incrementUsernameRepeatCount() -> Void {
        utilsCollection.document("username-counter").updateData([
            "counter": FieldValue.increment(Int64(1)) // FIXME: Avoid missing an increase: https://cloud.google.com/firestore/docs/solutions/counters
        ])
    }
    
    /** Provides a COMPLETION block with a USER constructed from the Firestore
     'users' collection, found by their EMAIL. If one user is found, then ERROR
     will be nil, but will have differing subtypes if there are no or multiple
     users returned by the query. */
    static func getUserFromEmail(_ email: String, _ completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        let userQuery = usersCollection.whereField("email", isEqualTo: email)
        userQuery.getDocuments { querySnapshot, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard !querySnapshot!.documents.isEmpty else {
                completion(nil, APIHandlerError.emptyRequest("There were no users found with the email: \(email)"))
                return
            }
            guard querySnapshot!.documents.count == 1 else {
                completion(nil, APIHandlerError.ambiguousRequest("There were many users found with the email: \(email)"))
                return
            }
            let userDocumentID = querySnapshot!.documents[0].documentID
            let docRef = db.collection("users").document(userDocumentID)
            docRef.getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    completion(user, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
    
    /** Attempts to delete the current user from the authentication database.
     Useful for failed registration processes, where the user was successfully
     persisted with the authentication service but failed at the database,
     preventing users with credentials but no place for their user data. */
    static func attemptToDeleteCurrentUser() {
        Auth.auth().currentUser?.delete()
    }
    
    /** Constructs and returns the user model corresopnding to the current
     authenticated user, if there is one. */
    static func getCurrentUserModel(_ completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        if let email = Auth.auth().currentUser?.email {
            APIHandler.getUserFromEmail(email) { user, error in
                completion(user, error)
            }
        } else {
            completion(nil, APIHandlerError.noAuthenticatedUser("No user is currently authenticated."))
        }
    }
    
    /** Ends the current API session to complete the log out process. Returns
     true if successful. */
    static func terminateAuthSession() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch _ {
            return false
        }
    }
}
