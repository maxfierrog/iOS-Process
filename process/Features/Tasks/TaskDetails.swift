//
//  TaskDetails.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Includes the ability to add subtasks to a task, edit its details, or to
 view details of its subtasks by creating another instance of itself, making
 it a recursive object of sorts. */
struct TaskDetailsView: View {
    
    @ObservedObject var model: TaskDetailsViewModel
    
    /* MARK: View declaration */
    
    var body: some View {
        VStack {
            NavigationLink(destination: TaskDetailsView(model: TaskDetailsViewModel(model)), tag: true, selection: $model.navigateToTaskDetails) { }
            
            HStack {
                Text(model.thisTask.data.description ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            HStack {
                GroupBox {
                    Text(model.formattedDueDate())
                }
                
                Spacer()
                
                GroupBox {
                    Text("Size: " + String(model.thisTask.data.size))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            
            GroupBox {
                TaskListView(model: TaskListViewModel(model))
            } label: {
                Text("Subtasks:")
            }
            .padding(.horizontal)
        }
        .accentColor(GlobalConstant.accentColor)
        .onAppear(perform: model.refreshTaskList)
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
        .sheet(isPresented: $model.navigateToSelectSubtasks) {
            NavigationView {
                SelectSubtasksView(model: SelectSubtasksViewModel(model))
            }
        }
        .sheet(isPresented: $model.navigateToEditTask) {
            NavigationView {
                EditTaskView(model: EditTaskViewModel(model))
            }
        }
        .navigationTitle(model.thisTask.data.name)
    }
}


class TaskDetailsViewModel: TaskListParent, ObservableObject {
    
    /* MARK: Model fields */
    
    var parentModel: TaskListParent
    
    // Navigation
    @Published var navigateToEditTask: Bool = false
    @Published var navigateToSelectSubtasks: Bool = false
    @Published var navigateToTaskDetails: Bool? = false
    
    // Fields
    @Published var selectedTask: Task = Task(creatorID: "")
    @Published var thisTask: Task
    @Published var user: User
    @Published var taskList: AsyncTaskList
    
    // Banner state fields
    @Published var showBanner: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier
        .BannerData(title: "", detail: "", type: .Info)
    
    /* MARK: Model initializer */
    
    init(_ model: TaskListParent) {
        self.user = model.user
        self.parentModel = model
        self.thisTask = model.selectedTask
        self.taskList = AsyncTaskList(model.selectedTask.data.subtasks)
    }
    
    /* MARK: Action methods */
    
    func tappedAddSubtask() {
        self.navigateToSelectSubtasks = true
    }
    
    func tappedEditTask() {
        self.navigateToEditTask = true
    }
    
    func tappedTask() {
        self.navigateToTaskDetails = true
    }
    
    func dismissChildView(_ named: String) {
        switch named {
        case "EditTaskView":
            self.navigateToEditTask = false
        case "SelectSubtasksView":
            self.navigateToSelectSubtasks = false
        default:
            return
        }
    }
    
    func refreshTaskList() {
        self.taskList = AsyncTaskList(self.thisTask.data.subtasks)
    }
    
    func showBannerWithSuccessMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericSuccessBannerTitle
        bannerData.detail = message
        bannerData.type = .Success
        showBanner = true
    }
    
    func formattedDueDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "PST")! as TimeZone
        return "Due " + dateFormatter.string(from: thisTask.data.dateDue)
    }
    
}
