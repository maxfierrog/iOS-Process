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
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem()], spacing: 8) {
                ForEach($model.availableSubtasks.items.indices, id: \.self) { index in
                    TaskCellView(model: TaskCellViewModel(task: model.availableSubtasks.items[index].task,
                                                          model: model))
                }
            }
        }
        .padding(.horizontal)
    }
}

class SelectSubtasksViewModel: ObservableObject, TaskListViewModel {
    
    @Published var user: User
    @Published var selectedTask: Task
    @Published var selectedSubtask: Task = Task(creatorID: "")
    @Published var availableSubtasks: AsyncTaskList
    @Published var parentModel: TaskListViewModel
    
    init(_ model: TaskDetailsViewModel) {
        self.parentModel = model
        self.selectedTask = model.selectedTask
        self.user = model.user
        self.availableSubtasks = model.user.taskList.getSubtaskOptions(task: model.selectedTask)
    }
    
    func taskSelected(task: Task) {
        self.selectedTask
            .addSubtask(task.data.id)
            .push() { error in
                guard error == nil else {
                    // Error banner
                    return
                }
                self.dismissView(successBanner: nil)
            }
    }
    
    private func dismissView(successBanner: String?) {
        self.parentModel.dismissEditTaskView()
        guard successBanner == nil else {
            self.parentModel.showBannerWithSuccessMessage(successBanner)
            return
        }
    }
    
    func dismissEditTaskView() {
        
    }
    
    func showBannerWithSuccessMessage(_ message: String?) {
        
    }
    
    
}
