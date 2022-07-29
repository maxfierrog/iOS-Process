//
//  TaskDetails.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct TaskDetailsView: View {
    
    @ObservedObject var model: TaskDetailsViewModel
    var body: some View {
        VStack {
            Text("...")
        }
        .navigationTitle(model.task.data.name)
    }
}

class TaskDetailsViewModel: ObservableObject {
    
    var tasksHomeViewModel: TasksHomeViewModel
    @Published var task: Task
    
    init(_ model: TasksHomeViewModel) {
        self.tasksHomeViewModel = model
        self.task = model.selectedTask
    }
}

struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
