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
    @Published var project: Project
    
    init(project: Project, model: TaskMeddlerModel) {
        self.parentModel = model
        self.project = project
    }
    
    func setToProject() {
        self.parentModel.setToProject(self.project)
    }
    
}
