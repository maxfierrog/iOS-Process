//
//  Super.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//


import SwiftUI


/** Root view managing access between verification and home views. */
struct RootView: View {
        
    @StateObject var model = RootViewModel()
    
    /* MARK: Superview fork */
    
    var body: some View {
        if (model.userSignedIn) {
            HomeView(model: HomeViewModel(model))
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
        } else {
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
        let previewUser = User()
        previewUser
            .changeName("Preview User")
            .changeUsername("username")
            .changeEmail("name@email.com")
            .finishEdit()
        
        self.user = previewUser
        self.userSignedIn = false
        
        APIHandler.pullAuthenticatedUser { user, error in
            guard error == nil && user != nil else { return }
            self.user = user!
            User.user = self.user
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
    
    func loginUser(_ user: User) {
        self.user = user
        self.userSignedIn = true
        self.user.pullProfilePicture() { error, _ in
            guard error == nil else { return }
        }
    }

}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
