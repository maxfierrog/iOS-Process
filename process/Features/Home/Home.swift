//
//  Home.swift
//  process
//
//  Created by maxfierro on 7/18/22.
//


import SwiftUI


/** Root tab bar controlling access to Projects, Tasks, and Profile views,
 containing the model of the user currently signed in. */
struct HomeView: View {
    
    /* MARK: Struct fields */
    
    @Binding var currentUser: User
    
    /* MARK: View declaration */
    
    var body: some View {
        TabView {
            ProjectsHomeView(user: $currentUser)
                .tabItem {
                    Label("Projects", systemImage: "list.dash")
                }

            TasksHomeView(user: $currentUser)
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }
            
            ProfileHomeView(user: $currentUser)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(currentUser: .constant(User(name: "Max Fierro", username: "", email: "")))
    }
}
