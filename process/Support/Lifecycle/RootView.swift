//
//  Super.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//


import SwiftUI


/** Root view managing access between verification and home views. */
struct RootView: View {
        
    @ObservedObject var model = RootViewModel()
    
    /* MARK: Superview fork */
    
    var body: some View {
        if (model.userSignedIn) {
            HomeView(model: HomeViewModel(model))
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
        }
        if (!model.userSignedIn) {
            LoginView(model: LoginViewModel(model))
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
        }
    }
}


/** Model for determining the authentication state of the application, and
 switching between login/registration and home views accordingly. */
class RootViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    @Published var userSignedIn: Bool
    @Published var user: User
    
    /* MARK: Model methods */
    
    /** Check for existing Authentication session, and extract current user's
     model if there is one. */
    init() {
        self.user = User(name: "Preview User",
                         username: "username",
                         email: "name@email.com")
        self.userSignedIn = false
        APIHandler.pullUserData { user, error in
            guard error == nil && user != nil else { return }
            self.user = user!
            self.user.pullProfilePicture() { error, _ in
                guard error == nil else { return }
                self.userSignedIn = true
            }
        }
    }
    
    /** Root logout. All child views' logout methods eventually call this
     one. Returns true if successful, providing child views information for
     displaying error banners. */
    func logOut() -> Bool {
        guard APIHandler.terminateAuthSession() else { return false }
        self.userSignedIn = false
        self.user = User()
        return true
    }
    
    func loginWithUserModel(_ user: User) {
        self.user = user
        self.userSignedIn = true
        self.user.pullProfilePicture() { error, _ in
            guard error == nil else { return }
        }
    }
    
    func updateUserModel(_ user: User) {
        self.user = user
    }

}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
