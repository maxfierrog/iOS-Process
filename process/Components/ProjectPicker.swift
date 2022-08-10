//
//  ProjectPicker.swift
//  process
//
//  Created by maxfierro on 7/29/22.
//

import SwiftUI


struct ProjectsListItemView: View {
    
    @ObservedObject var model: ProjectPickerViewModel
    
    var body: some View {
        Button {
            model.setToProject()
        } label: {
            Text(model.project.data.name)
        }
        .buttonStyle(.bordered)
    }
}


class ProjectPickerViewModel: ObservableObject {
    
    var parentModel: TaskMeddlerModel
    @Published var projectID: String
    @Published var project: Project = Project(creatorID: "")
    
    init(projectID: String, parentModel: TaskMeddlerModel) {
        self.projectID = projectID
        self.parentModel = parentModel
        Project.pull(projectID) { project, error in
            guard error == nil else { return }
            self.project = project!
        }
    }
    
    func setToProject() {
        self.parentModel.setToProject(self.project)
    }
    
}
