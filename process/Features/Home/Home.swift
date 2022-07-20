//
//  Home.swift
//  process
//
//  Created by maxfierro on 7/18/22.
//


import SwiftUI


/** Root tab bar controlling access to Projects, Tasks, and Profile views. */
struct HomeView: View {
    
    /* MARK: Struct fields */
    
    @ObservedObject var model: HomeViewModel
    
    /* MARK: View declaration */
    
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
    }
}


/** Serves as a communication bridge between the three Home views'
 controllers and the Super view controller. This is to simplifiy the logout
 procedure with regards to navigation and code reduction. */
class HomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // SuperView model
    var superModel: SuperViewModel
    @Published var currentUser: User
    
    /* MARK: Model methods */
    
    init(_ superModel: SuperViewModel) {
        self.superModel = superModel
        self.currentUser = superModel.getSignedInUser()
    }
    
    func logOut() -> Bool {
        return superModel.logOut()
    }
    
    func getCurrentUser() -> User {
        return self.currentUser
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(SuperViewModel()))
    }
}
