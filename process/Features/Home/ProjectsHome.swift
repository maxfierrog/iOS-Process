//
//  ProjectsHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Allows user to view ongoing and finished projects they created or are
 collaborators in, with the option to navigate to their Details views. */
struct ProjectsHomeView: View {
    
    /* MARK: Struct fields */
    
    @StateObject var model: ProjectsHomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: View declaration */

    var body: some View {
        VStack {
            Picker(ProjectsConstant.pickerAccessibilityText, selection: $model.selectedProjectCategory) {
                ForEach(model.projectCategories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
        }
        .roundButton(
            color: GlobalConstant.accentColor,
            image: Image(systemName: "plus").foregroundColor(colorScheme == .dark ? .black : .white)) {
            model.tappedNewProject()
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedNotifications()
                } label: {
                    Label(ProjectsConstant.notificationsAccessibilityText, systemImage: ProjectsConstant.notificationsButtonIcon)
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


/** Data model for the Projects view. Communicates with Home view's model to
 obtain data and to communicate instructions, such as logging out. */
class ProjectsHomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // HomeView parent model
    var homeViewModel: HomeViewModel
    @Published var user: User
    
    // Segmented control
    @Published var projectCategories: [String] = ProjectsConstant.projectCategories
    @Published var selectedProjectCategory: Int = ProjectsConstant.startingProjectCategory
    
    // UI state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    // Search bar
    @Published var searchText: String = ""
    
    /* MARK: Model methods */
    
    init(_ homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self.user = homeViewModel.getCurrentUser()
    }
    
    func tappedLogOut() {
        if (!self.homeViewModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    func tappedNotifications() {
        // FIXME: Show notifications view
    }
    
    func tappedNewProject() {
        // FIXME: Generate new projects
    }
    
    /* MARK: Model helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = ProjectsConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showBanner = true
    }
    
}


struct ProjectsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(SuperViewModel()))
            .preferredColorScheme(.light)
    }
}
