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
    
    @Binding var user: User
    @StateObject private var model = ProjectsHomeViewModel()
    @FocusState private var focus: FocusableRegistrationField?
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: View declaration */

    var body: some View {
        VStack {
            Picker("Task category:", selection: $model.selectedTaskCategory) {
                ForEach(0..<3) { index in
                    Text(model.taskCategories[index])
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
        }
    }
}


/** Data model for the Projects view. */
class ProjectsHomeViewModel: ObservableObject {
    
    /* MARK: Class fields */
    
    // Segmented control options
    @Published var taskCategories: [String] = ["New", "WIP", "Done"]
    @Published var selectedTaskCategory: Int = 0
    
    /* MARK: Class methods */
    
}


struct ProjectsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsHomeView(user: .constant(User(name: "Max Fierro", username: "", email: "")))
    }
}
