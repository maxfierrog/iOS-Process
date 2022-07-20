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
    
    /* MARK: Struct fields */
    
    @StateObject var model: ProfileHomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: View declaration */
    
    var body: some View {
        VStack {
            GroupBox {
                HStack {
                    HStack {
                        Spacer()
                        Image(model.getProfilePicture())
                            .resizable()
                            .frame(width: 125, height: 125)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(.gray, lineWidth: 4)
                            }
                            .shadow(radius: 7)
                            .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 10))
                    }
                    VStack {
                        HStack {
                            Text(model.user.name)
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(model.user.username)
                                .font(.title3)
                                .padding(.bottom, 3)
                            Spacer()
                        }
                        HStack {
                            Button(action: {
                                model.editing.toggle()
                            }, label: {
                                Text("Edit")
                                    .font(.subheadline)
                            })
                            .buttonStyle(.bordered)
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            .padding()
            
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
    
    // Editing
    @Published var editing: Bool = false
    
    /* MARK: Model methods */
    
    init(_ model: HomeViewModel) {
        self.homeViewModel = model
        self.user = model.currentUser
    }
    
    func getProfilePicture() -> String {
        return ProfileConstant.defaultProfilePicture
    }
    
    func tappedPreferences() {
        // FIXME: Show preferences view
    }
    
    func tappedEditProfile() {
        // FIXME: Show profile edit view
    }
    
    func tappedLogOut() {
        if (!self.homeViewModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    /* MARK: Model helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = ProfileConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showBanner = true
    }
}

struct ProfileHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHomeView(model: ProfileHomeViewModel(HomeViewModel(SuperViewModel())))
    }
}
