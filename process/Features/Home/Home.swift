//
//  Home.swift
//  process
//
//  Created by maxfierro on 7/18/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            ProjectsHomeView()
                .tabItem {
                    Label("Projects", systemImage: "list.dash")
                }

            TasksHomeView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }
            
            ProfileHomeView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
