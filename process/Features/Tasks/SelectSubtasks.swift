//
//  SelectSubtasks.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


struct SelectSubtasksView: View {
    
    @ObservedObject var model: SelectSubtasksViewModel
    
    /* MARK: View declaration */
    
    var body: some View {
        TaskListView(model: TaskListViewModel(model))
            .padding(.horizontal)
            .navigationTitle("Select Subtasks")
    }
}


class SelectSubtasksViewModel: TaskListParent, ObservableObject {
    
    @Published var user: User
    @Published var thisTask: Task
    @Published var selectedTask: Task = Task(creatorID: "")
    @Published var taskList: AsyncTaskList
    @Published var parentModel: TaskDetailsViewModel
    
    init(_ model: TaskDetailsViewModel) {
        self.user = model.user
        self.parentModel = model
        self.thisTask = model.thisTask
        self.taskList = model.user.taskList.getSubtaskOptions(task: model.thisTask)
    }
    
    func tappedTask() {
        self.thisTask
            .addSubtask(selectedTask.data.id)
            .push() { error in
                guard error == nil else { return }
                self.dismissView(successBanner: nil)
            }
    }
    
    private func dismissView(successBanner: String?) {
        self.parentModel.dismissChildView("SelectSubtasksView")
        guard successBanner == nil else {
            self.parentModel.showBannerWithSuccessMessage(successBanner)
            return
        }
    }
    
    func dismissChildView(_ named: String) { return }
    
    func showBannerWithSuccessMessage(_ message: String?) { return }
    
}
