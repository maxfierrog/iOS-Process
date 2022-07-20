//
//  Super.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//


import SwiftUI


/** Root view managing access between verification and home views. */
struct SuperView: View {
    
    /* MARK: Struct fields */
    
    @ObservedObject var model = SuperViewModel()
    
    /* MARK: View declaration */
    
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
class SuperViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    @Published var userSignedIn: Bool
    @Published var signedInUser: User
    
    /* MARK: Model methods */
    
    /** Check for existing Authentication session, and extract current user's
     model if there is one. */
    init() {
        self.signedInUser = User()
        self.userSignedIn = false
        APIHandler.getCurrentUserModel { user, error in
            guard error == nil && user != nil else { return }
            self.signedInUser = user!
            self.userSignedIn = true
        }
    }
    
    /** Root logout. All child views' logout methods eventually call this
     one. Returns true if successful, providing child views information for
     displaying error banners. */
    func logOut() -> Bool {
        guard APIHandler.terminateAuthSession() else { return false }
        self.userSignedIn = false
        self.signedInUser = User()
        return true
    }
    
    func loginWithUserModel(_ model: User) {
        self.signedInUser = model
        self.userSignedIn = true
    }
    
    func getSignedInUser() -> User {
        return self.signedInUser
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        SuperView()
    }
}
