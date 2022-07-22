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
            NavigationLink(destination: UserPreferencesView(), tag: true, selection: $model.navigateToPreferences) { }
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
        .sheet(isPresented: $model.navigateToChoosePhoto) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $model.profilePictureImage)
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
                Image(uiImage: model.profilePictureImage)
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
                        withAnimation {
                            model.chooseProfilePicture()
                        }
                    } label: {
                        Text("Choose Profile Picture")
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button {
                        withAnimation {
                            model.saveUserData()
                        }
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
    
    // Navigation
    @Published var navigateToPreferences: Bool? = false
    
    // Profile picture
    @Published var profilePictureImage: UIImage
    @Published var navigateToChoosePhoto: Bool = false
    
    // Banner state fields
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
        self.profilePictureImage = UIImage(named: ProfileConstant.defaultProfilePicture)!
        APIHandler.fetchImageFromStorage(user: model.getUser()) { error, image in
            guard error == nil else { return }
            self.profilePictureImage = image!
        }
    }
    
    func chooseProfilePicture() {
        self.navigateToChoosePhoto = true
    }
    
    func tappedPreferences() {
        // FIXME: Show preferences view
    }
    
    func getProfilePicture() -> UIImage {
        return self.profilePictureImage
    }
    
    func tappedEditProfile() {
        if self.editing {
            self.localName = self.user.name
            self.localUsername = self.user.username
            self.profilePictureImage = UIImage(named: ProfileConstant.defaultProfilePicture)! // FIXME: Only works if the user's image is the default one
        }
        self.editing.toggle()
    }
    
    func saveUserData() {
        if (self.user.username != self.localUsername) {
            APIHandler.matchUsernameQuery(user.username) { result, error in
                guard error == nil else {
                    self.showBannerWithErrorMessage(error?.localizedDescription)
                    return
                }
                guard result!.documents.isEmpty else {
                    self.showBannerWithErrorMessage("Sorry, that username already exists. Please choose another one.")
                    return
                }
                let updatedDataModel = User(
                    copyOf: self.user,
                    name: self.localName,
                    username: self.localUsername
                )
                self.updateUserModel(updatedDataModel)
                self.editing = false
            }
        } else {
            let updatedDataModel = User(
                copyOf: self.user,
                name: self.localName,
                username: self.localUsername
            )
            self.updateUserModel(updatedDataModel)
            self.editing = false
        }
    }
    
    func updateUserModel(_ newModel: User) {
        APIHandler.uploadUser(newModel) { error in
            guard error == nil else {
                self.showBannerWithErrorMessage(error?.localizedDescription)
                return
            }
            self.homeViewModel.updateUserModel(newModel)
            self.user = newModel
            let uploadTask = APIHandler.uploadImageToStorage(image: self.profilePictureImage, user: self.user) { error, _ in
                guard error == nil else {
                    self.showBannerWithErrorMessage(error?.localizedDescription)
                    return
                }
            }
            uploadTask.resume()
            self.showBannerWithSuccessMessage("Successfully changed your user data.")
        }
    }
    
    func tappedLogOut() {
        if (!self.homeViewModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    /* MARK: Helper methods */
    
    func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showBanner = true
    }
    
    func showBannerWithSuccessMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericSuccessBannerTitle
        bannerData.detail = message
        bannerData.type = .Success
        showBanner = true
    }
    
}

struct ProfileHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHomeView(model: ProfileHomeViewModel(HomeViewModel(SuperViewModel())))
    }
}
