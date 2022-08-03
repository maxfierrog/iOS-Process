//
//  TaskDetails.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** The models for views which contain clickable lists of tasks must conform
 to this protocol. */
protocol TaskListViewModel {
    
    // Should know which task was clicked on within the list
    var selectedTask: Task { get set }
    
    // Should know the user interacting with the list
    var user: User { get set }
    
    // Should have an action happen when a task is chosen
    func taskSelected(task: Task) -> Void
    
    // Should be able to dismiss an edit/new task screen (cancel button)
    func dismissEditTaskView() -> Void
    
    // Should be able to communicate events in children views through banners
    func showBannerWithSuccessMessage(_ message: String?) -> Void
}


/** Includes the ability to add subtasks to a task, edit its details, or to
 view details of its subtasks by creating another instance of itself, making
 it a recursive object of sorts. */
struct TaskDetailsView: View {
    
    @ObservedObject var model: TaskDetailsViewModel
    
    /* MARK: View declaration */
    
    var body: some View {
        VStack {
            NavigationLink(destination: SelectSubtasksView(model: SelectSubtasksViewModel(model)), tag: true, selection: $model.navigateToSelectSubtasks) { }
            NavigationLink(destination: TaskDetailsView(model: TaskDetailsViewModel(model)), tag: true, selection: $model.navigateToTaskDetails) { }
            
            HStack {
                Text(model.selectedTask.data.description ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            GroupBox {
                ScrollView(.vertical) {
                    LazyVGrid(columns: model.taskListColumn, spacing: 8) {
                        ForEach($model.subtaskList.items.indices, id: \.self) { index in
                            TaskCellView(model: TaskCellViewModel(task: model.subtaskList.items[index].task,
                                                                  model: model))
                        }
                    }
                }
            } label: {
                Text("Subtasks:")
            }
            .padding(.horizontal)
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedAddSubtask()
                } label: {
                    Label("Add subtask", systemImage: "rectangle.center.inset.filled.badge.plus")
                }
                Button {
                    model.tappedEditTask()
                } label: {
                    Label("Edit task", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $model.navigateToEditTask) {
            NavigationView {
                EditTaskView(model: EditTaskViewModel(model, isNewTask: false))
            }
        }
        .navigationTitle(model.selectedTask.data.name)
    }
}


class TaskDetailsViewModel: ObservableObject, TaskListViewModel {
    
    /* MARK: Model fields */
    
    // Navigation
    @Published var navigateToEditTask: Bool = false
    @Published var navigateToSelectSubtasks: Bool? = false
    @Published var navigateToTaskDetails: Bool? = false
    
    // Parent model
    var parentModel: TaskListViewModel
    @Published var selectedTask: Task
    @Published var user: User = User()
    
    // Task list
    @Published var taskListColumn: [GridItem] = [GridItem()]
    @Published var subtaskList: AsyncTaskList
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    /* MARK: Model initializer */
    
    init(_ model: TaskListViewModel) {
        self.parentModel = model
        self.user = model.user
        self.selectedTask = model.selectedTask
        self.subtaskList = AsyncTaskList(model.selectedTask.data.subtasks)
    }
    
    /* MARK: Action methods */
    
    func tappedAddSubtask() {
        self.navigateToSelectSubtasks = true
    }
    
    func tappedEditTask() {
        self.navigateToEditTask = true
    }
    
    func taskSelected(task: Task) {
        self.navigateToTaskDetails = true
    }
    
    func dismissEditTaskView() {
        self.navigateToEditTask = false
    }
    
    func showBannerWithSuccessMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericSuccessBannerTitle
        bannerData.detail = message
        bannerData.type = .Success
        showBanner = true
    }
    
}
