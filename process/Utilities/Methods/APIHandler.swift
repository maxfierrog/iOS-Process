//
//  APIHandler.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//


import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseStorage
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
    
    // Realtime database
    static private let realtimeDB = Firestore.firestore()
    static private let usersCollection = realtimeDB.collection("users")
    static private let invitesCollection = realtimeDB.collection("invites")
    static private let projectsCollection = realtimeDB.collection("projects")
    static private let tasksCollection = realtimeDB.collection("tasks")
    static private let utilsCollection = realtimeDB.collection("utils")
    
    // Storage database
    static private let storageDB = Storage.storage()
    static private let storageRef = storageDB.reference()
    static private let imagesRef = storageRef.child("images")
    
    /* MARK: Utility methods */

    /** Uploads a new User struct model USER to Firestore. Allows for a
     COMPLETION block with an ERROR parameter, which will be nil if the upload
     was successful. If a user with the same ID exists in the database, the
     entry will be replaced. */
    static func uploadUser(_ user: User, _ completion: @escaping(_ error: Error?) -> Void) {
        do {
            try realtimeDB.collection("users").document(user.id).setData(from: user)
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
            let docRef = realtimeDB.collection("users").document(userDocumentID)
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
    
    /** Uploads an image reference with DATA to the images folder in the
     storage database, with NAME for its path termination. Allows for a
     completion block for errors and metadata. */
    static func uploadImageToStorage(image: UIImage, user: User, _ completion: @escaping(_ error: Error?, _ metadata: StorageMetadata?) -> Void) -> StorageUploadTask {
        let pictureCopy = image
        let pictureData = pictureCopy.resized(to: CGSize(width: 512, height: 512)).jpegData(compressionQuality: 0.9)! //FIXME: Image resizing doesn't work
        let pictureRef = APIHandler.imagesRef.child(user.id)
        return pictureRef.putData(pictureData, metadata: StorageMetadata()) { metadata, error in
            guard error == nil else {
                completion(error, nil)
                return
            }
            guard metadata != nil else {
                completion(APIHandlerError.dataUploadFailed("Could not upload profile picture reference to storage."), nil)
                return
            }
            pictureRef.downloadURL { url, error in
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                guard url != nil else {
                    completion(APIHandlerError.dataUploadFailed("Could not download reference to picture URL."), nil)
                    return
                }
                completion(nil, metadata)
            }
        }
    }
    
    /** Fetches a user's profile picture from storage. User's profile picctures
     are stored in the images directory, and are named with their IDs. */
    static func fetchImageFromStorage(user: User, _ completion: @escaping(_ error: Error?, _ image: UIImage?) -> Void) {
        let pictureRef = APIHandler.imagesRef.child(user.id)
        pictureRef.getData(maxSize: 1 * 2048 * 2048) { data, error in // FIXME: MaxSize too generous, temp fix for disfunctional resizing
            guard error == nil else {
                completion(error, nil)
                return
            }
            print("Fetched")
            completion(nil, UIImage(data: data!))
        }
    }
    
    
}

/** Extension of UIImage with resizing method. */
extension UIImage {
    public func resized(to target: CGSize) -> UIImage {
        let ratio = min(
            target.height / size.height, target.width / size.width
        )
        let new = CGSize(
            width: size.width * ratio, height: size.height * ratio
        )
        let renderer = UIGraphicsImageRenderer(size: new)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: new))
        }
    }
}
