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
    
    /* MARK: Database references */
    
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
    
    /* MARK: Username colision */
    
    /** Generates and passes a unique username RESULT based on a user screen
     NAME. This is ensured by adding an integer counter which only increases
     to the end of existing usernames to ensure uniqueness. */
    static func availableUsernameFromName(_ name: String, _ completion: @escaping(_ result: String?, _ error: Error?) -> Void) {
        let noWhitespaceName: String = String(name.filter { !" \n\t\r".contains($0) }).lowercased()
        APIHandler.matchUsernameQuery(noWhitespaceName) { query, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            if (!query!.documents.isEmpty) {
                APIHandler.getUsernameRepeatCount { count, error in
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    APIHandler.incrementUsernameRepeatCount()
                    completion(noWhitespaceName + String(count!), nil)
                }
            } else {
                completion(noWhitespaceName, nil)
            }
        }
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
    
    /* MARK: Authentication */
    
    /** Returns true if EMAIL is not malformed. */
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
            let docRef = usersCollection.document(userDocumentID)
            docRef.getDocument(as: UserData.self) { result in
                switch result {
                case .success(let userData):
                    completion(User.instance(userData), nil)
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
    
    /** Returns the Firebase Authentication service ID of the current user.
     Throws noAuthenticatedUser error if  there is no user authenticated. */
    static func currentUserAuthID() throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIHandlerError.noAuthenticatedUser("No user is currently authenticated.")
        }
        return user.uid
    }
    
    /* MARK: Push/pull user */
    
    /** Uploads a new User struct model USER to Firestore. Allows for a
     COMPLETION block with an ERROR parameter, which will be nil if the upload
     was successful. If a user with the same ID exists in the database, the
     entry will be replaced. */
    static func pushUser(_ user: User, _ completion: @escaping(_ error: Error?) -> Void) {
        do {
            try usersCollection.document(user.data.id).setData(from: user.data)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    /** Constructs and returns the user model corresopnding to an ID. */
    static func pullCurrentUser(_ id: String, _ completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        let docRef = usersCollection.document(id)
        docRef.getDocument(as: UserData.self) { result in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let userData):
                completion(User.instance(userData), nil)
            }
        }
    }
    
    /** Constructs and returns the user model corresopnding to the current
     authenticated user, if there is one. */
    static func pullAuthenticatedUser(_ completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        if let email = Auth.auth().currentUser?.email {
            getUserFromEmail(email) { user, error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(user, nil)
            }
        } else {
            completion(nil, APIHandlerError.noAuthenticatedUser("No user is currently authenticated."))
        }
    }
    
    /* MARK: Push/pull profile pictures */
    
    /** Uploads an image reference with DATA to the images folder in the
     storage database, with NAME for its path termination. Allows for a
     completion block for errors and metadata. */
    static func pushProfilePicture(_ image: UIImage, userID: String, _ completion: @escaping(_ error: Error?, _ metadata: StorageMetadata?) -> Void) -> StorageUploadTask {
        let pictureData = image.resized(to: CGSize(width: 512, height: 512)).jpegData(compressionQuality: 0.9)! //FIXME: Image resizing doesn't work
        let pictureRef = APIHandler.imagesRef.child(userID)
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
    static func pullProfilePicture(userID: String, _ completion: @escaping(_ error: Error?, _ image: UIImage?) -> Void) {
        let pictureRef = APIHandler.imagesRef.child(userID)
        pictureRef.getData(maxSize: 1 * 2048 * 2048) { data, error in // FIXME: MaxSize too generous, temp fix for disfunctional resizing
            guard error == nil else {
                completion(error, nil)
                return
            }
            completion(nil, UIImage(data: data!))
        }
    }
    
    /* MARK: Push/pull projects */
    
    /** Uploads a block of project data to Firestore, allowing for a completion
     block with an error if there was one in the process. */
    static func pushProject(_ project: Project, _ completion: @escaping(_ error: Error?) -> Void) {
        do {
            try projectsCollection.document(project.data.id).setData(from: project.data)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }

    /** Returns the generated Project model from ID, stored in Firestore. */
    static func pullProject(projectID: String, _ completion: @escaping(_ project: Project?, _ error: Error?) -> Void){
        let docRef = projectsCollection.document(projectID)
        docRef.getDocument(as: ProjectData.self) { result in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let projectData):
                completion(Project(projectData), nil)
            }
        }
    }
    
    /* MARK: Push/pull tasks */
    
    /** Uploads a block of project data to Firestore, allowing for a completion
     block with an error if there was one in the process. */
    static func pushTask(_ task: Task, _ completion: @escaping(_ error: Error?) -> Void) {
        removeTaskFromProject(taskID: task.data.id) { error in
            guard error == nil else {
                completion(error)
                return
            }
            addTaskToProject(taskID: task.data.id, projectID: task.data.project) { error in
                guard error == nil else {
                    completion(error)
                    return
                }
                do {
                    try tasksCollection.document(task.data.id).setData(from: task.data)
                    completion(nil)
                } catch let error {
                    completion(error)
                }
            }
        }
    }

    /** Returns the generated Project model from ID, stored in Firestore. */
    static func pullTask(taskID: String, _ completion: @escaping(_ task: Task?, _ error: Error?) -> Void){
        let docRef = tasksCollection.document(taskID)
        docRef.getDocument(as: TaskData.self) { result in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let taskData):
                completion(Task(taskData), nil)
            }
        }
    }
    
    /** Removes TASK's document from storage in Firestore, as well as its
     reference from its assigned project if there is one. */
    static func deleteTask(_ task: Task, _ completion: @escaping(_ error: Error?) -> Void){
        let taskCollectionRef = tasksCollection.document(task.data.id)
        do {
            let userTaskListRef = try usersCollection.document(APIHandler.currentUserAuthID())
            taskCollectionRef.delete { error in
                guard error == nil else {
                    completion(error)
                    return
                }
                userTaskListRef.delete() { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    APIHandler.removeTaskFromProject(taskID: task.data.id) { error in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        completion(nil)
                    }
                }
            }
        } catch let error {
            completion(error)
        }
    }
    
    /** If a project contains the task with TASKID, then we remove it from its
     list of tasks and allow for actions through a completion block. If no
     project contains the task, then the completion block is just executed. */
    static func removeTaskFromProject(taskID: String, _ completion: @escaping(_ error: Error?) -> Void) {
        let containedInProject = projectsCollection.whereField("tasks", arrayContains: taskID)
        containedInProject.getDocuments { querySnapshot, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard querySnapshot!.documents.isEmpty else {
                do {
                    let projectData: ProjectData? = try querySnapshot?.documents[0].data(as: ProjectData.self)
                    let project = Project(projectData!)
                    project
                        .removeTask(taskID)
                        .push { error in
                            guard error == nil else {
                                completion(error)
                                return
                            }
                            completion(nil)
                        }
                } catch let error {
                    completion(error)
                }
                return
            }
            completion(nil)
        }
    }
    
    /** Adds TASKID to the tasks of the project with PROJECTID, or gives a
     non-null error in its completion block if there is no such project. */
    static func addTaskToProject(taskID: String, projectID: String?, _ completion: @escaping(_ error: Error?) -> Void) {
        guard projectID != nil else {
            completion(nil)
            return
        }
        pullProject(projectID: projectID!) { project, error in
            guard error == nil else {
                completion(error)
                return
            }
            project?
                .addTask(taskID)
                .push { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    completion(nil)
                }
        }
    }
}
