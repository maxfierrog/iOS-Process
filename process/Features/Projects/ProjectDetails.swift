//
//  ProjectDetails.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct ProjectDetailsView: View {
    
    @ObservedObject var model: ProjectDetailsViewModel
    
    var body: some View {
        VStack {
            Text("...")
        }
        .navigationTitle(model.project.data.name)
    }
}

class ProjectDetailsViewModel: ObservableObject {
    
    var projectsHomeViewModel: ProjectsHomeViewModel
    @Published var project: Project = Project()
    
    init(_ model: ProjectsHomeViewModel) {
        self.projectsHomeViewModel = model
        self.project = model.selectedProject
    }
}

struct ProjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
