//
//  Home.swift
//  process
//
//  Created by maxfierro on 7/18/22.
//


import SwiftUI


/** Root tab bar controlling access to Projects, Tasks, and Profile views. */
struct HomeView: View {
        
    @ObservedObject var model: HomeViewModel
    
    /* MARK: Home view declaration */
    
    var body: some View {
        TabView {
            NavigationView {
                ProjectsHomeView(model: ProjectsHomeViewModel(model))
                    .navigationTitle(ProjectsConstant.navigationTitle)
            }
            .tabItem {
                Label(HomeConstants.projectsTabButtonText, systemImage: HomeConstants.projectsTabButtonIcon)
            }
            
            NavigationView {
                TasksHomeView(model: TasksHomeViewModel(model))
                    .navigationTitle(TasksConstant.navigationTitle)
            }
            .tabItem {
                Label(HomeConstants.tasksTabButtonText, systemImage: HomeConstants.tasksTabButtonIcon)
            }
            
            NavigationView {
                ProfileHomeView(model: ProfileHomeViewModel(model))
                    .navigationTitle(ProfileConstant.navigationTitle)
            }
            .tabItem {
                Label(HomeConstants.profileTabButtonText, systemImage: HomeConstants.profileTabButtonIcon)
            }
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
    }
}


/** Serves as a communication bridge between the three Home views'
 controllers and the Super view controller. This is to simplifiy the logout
 procedure with regards to navigation and code reduction. */
class HomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // SuperView model
    var superModel: SuperViewModel
    @Published private var user: User
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    /* MARK: Model methods */
    
    init(_ superModel: SuperViewModel) {
        self.superModel = superModel
        self.user = superModel.getUser()
    }
    
    func updateUserModel(_ newModel: User) {
        self.superModel.updateUserModel(newModel)
        self.user = newModel
    }
    
    func logOut() -> Bool {
        return superModel.logOut()
    }
    
    func getUser() -> User {
        return superModel.getUser()
    }
    
    func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = ProjectsConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showBanner = true
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(SuperViewModel()))
    }
}
