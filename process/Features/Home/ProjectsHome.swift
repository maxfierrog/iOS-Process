//
//  ProjectsHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct ProjectsHomeView: View {
    
    @Binding var user: User
    @StateObject private var model = ProjectsHomeViewModel()
    @FocusState private var focus: FocusableRegistrationField?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Picker("Task category:", selection: $model.selectedTaskCategory) {
                ForEach(0..<3) { index in
                    Text(model.taskCategories[index])
                }
            }
        }
    }
}

class ProjectsHomeViewModel: ObservableObject {
    
    @Published var taskCategories: [String] = ["New", "WIP", "Done"]
    @Published var selectedTaskCategory: Int = 0
    
}

struct ProjectsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsHomeView(user: .constant(User(name: "Max Fierro", username: "", email: "")))
    }
}
