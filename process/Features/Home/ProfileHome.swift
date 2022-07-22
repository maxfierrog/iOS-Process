//
//  ProfileHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Allows the user to view and edit their personally identifying information,
 and to interface with account and privacy preferences. */
struct ProfileHomeView: View {
    
    @StateObject var model: ProfileHomeViewModel
    @Environment(\.colorScheme) private var colorScheme

    /* MARK: Profile home view */
    
    var body: some View {
        VStack {
            if (model.editing) {
                EditProfileCardView(model: model)
            }
            ProfileCardView(model: model)
                .onLongPressGesture {
                    withAnimation {
                        model.tappedEditProfile()
                    }
                }
            if (!model.editing) {
                AnalyticsScrollView(model: model)
            }
            Spacer()
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedPreferences()
                } label: {
                    Label(ProfileConstant.preferencesAccessibilityText, systemImage: ProfileConstant.preferencesButtonIcon)
                }
            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    withAnimation {
                        model.tappedLogOut()
                    }
                } label: {
                    Text(GlobalConstant.logoutButtonText)
                }
            }
        }
    }
}


/** A display card containing user identifying data. */
struct ProfileCardView: View {
    
    @StateObject var model: ProfileHomeViewModel
    
    /* MARK: Profile card view */
    
    var body: some View {
        GroupBox {
            HStack {
                Spacer()
                Image(model.getProfilePicture())
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.gray, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                    .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 10))
                VStack {
                    HStack {
                        Text(model.localName)
                            .font(.title2)
                            .bold()
                    }
                    HStack {
                        Text(model.localUsername)
                            .font(.title3)
                            .padding(.bottom, 3)
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
}


/** A display card containing user identifying data. */
struct EditProfileCardView: View {
    
    @StateObject var model: ProfileHomeViewModel
    
    /* MARK: Edit profile view */
    
    var body: some View {
        GroupBox {
            VStack {
                TextField(text: $model.localName, prompt: Text("Name")) {
                    Text("Screen name")
                }
                .padding(.bottom, 10)
                .padding(.top, 10)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                TextField(text: $model.localUsername, prompt: Text("Username")) {
                    Text("Screen name")
                }
                .padding(.bottom, 10)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                HStack {
                    Button {
                        model.chooseProfilePicture()
                    } label: {
                        Text("Choose Profile Picture")
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button {
                        model.saveUserData()
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(.bordered)
                }
            }
        } label: {
            Label("Edit user profile", systemImage: "square.and.pencil")
        }
        .padding()
    }
}


struct AnalyticsScrollView: View {
    
    @ObservedObject var model: ProfileHomeViewModel
    
    /* MARK: Analytics view */
    
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Text("User Analytics")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 24)
                
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(0..<10) { _ in
                        GroupBox {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: 200, height: 200)
                    }
                }
            }
        }
    }
}


/** Data model for the Profile view. Communicates with Home view's model to
 obtain data and to communicate instructions, such as logging out. */
class ProfileHomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // HomeView parent model
    private var homeViewModel: HomeViewModel
    @Published var user: User
    
    // UI state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    // Profile editing
    @Published var editing: Bool = false
    @Published var editorNameField: String = ""
    @Published var editorUsernameField: String = ""
    
    // Bridges
    @Published var localUsername: String
    @Published var localName: String
    
    /* MARK: Model methods */
    
    init(_ model: HomeViewModel) {
        self.homeViewModel = model
        self.user = model.getUser()
        self.localName = model.getUser().name
        self.localUsername = model.getUser().username
    }
    
    func chooseProfilePicture() {
        
    }
    
    func tappedPreferences() {
        // FIXME: Show preferences view
    }
    
    func getProfilePicture() -> String {
        return ProfileConstant.defaultProfilePicture
    }
    
    func tappedEditProfile() {
        if self.editing {
            self.localName = self.user.name
            self.localUsername = self.user.username
        }
        self.editing.toggle()
    }
    
    func saveUserData() {
        let updatedDataModel = User(
            copyOf: self.user,
            name: self.localName,
            username: self.localUsername
        )
        updateUserModel(updatedDataModel)
        self.editing = false
    }
    
    func updateUserModel(_ newModel: User) {
        APIHandler.uploadUser(newModel) { error in
            guard error == nil else {
                self.showBannerWithErrorMessage(error?.localizedDescription)
                return
            }
            self.homeViewModel.updateUserModel(newModel)
            self.user = newModel
        }
    }
    
    func tappedLogOut() {
        if (!self.homeViewModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    /* MARK: Model helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        self.homeViewModel.showBannerWithErrorMessage(message)
    }
}

struct ProfileHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHomeView(model: ProfileHomeViewModel(HomeViewModel(SuperViewModel())))
    }
}
