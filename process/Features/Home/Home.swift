//
//  Home.swift
//  process
//
//  Created by maxfierro on 7/18/22.
//

import SwiftUI

struct HomeView: View {
    
    @Binding var currentUser: User
    
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
