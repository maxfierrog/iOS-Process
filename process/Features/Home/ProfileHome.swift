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
            // FIXME: Add profile page contents
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
    
    /* MARK: Model methods */
    
    init(_ model: HomeViewModel) {
        self.homeViewModel = model
        self.user = model.currentUser
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
