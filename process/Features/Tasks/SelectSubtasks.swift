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
        GroupBox {
            TaskListView(model: TaskListViewModel(model))
                .navigationTitle("Select a Subtask")
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedRefresh()
                } label: {
                    Text("Refresh")
                }
                .buttonStyle(.bordered)
            }
            
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    model.tappedCancel()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .accentColor(GlobalConstant.accentColor)
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
    
    func tappedRefresh() {
        self.taskList = self.user.taskList.getSubtaskOptions(task: self.thisTask)
    }
    
    func tappedCancel() {
        self.parentModel.dismissChildView("SelectSubtasksView")
    }
    
    func dismissChildView(_ named: String) { return }
    
    func showBannerWithSuccessMessage(_ message: String?) { return }
    
    func refreshTaskList() {
        self.taskList = self.user.taskList.getSubtaskOptions(task: self.thisTask)
    }
    
}
