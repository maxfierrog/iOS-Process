//
//  TaskDetails.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

protocol TaskListViewModel {
    var selectedTask: Task { get set }
    var user: User { get set }
    func openTaskDetails(task: Task) -> Void
    func dismissNewTaskView() -> Void
    func showBannerWithSuccessMessage(_ message: String?) -> Void
}

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
    
    var parentModel: TaskListViewModel
    @Published var task: Task
    
    init(_ model: TaskListViewModel) {
        self.parentModel = model
        self.task = model.selectedTask
    }
}

struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
