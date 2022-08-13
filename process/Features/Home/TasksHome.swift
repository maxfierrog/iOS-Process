//
//  TasksHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Facilitates a summary of tasks for the user's convencience. */
struct TasksHomeView: View {
    
    @ObservedObject var model: TasksHomeViewModel
    @Environment(\.colorScheme) private var colorScheme
        
    /* MARK: Tasks home view */

    var body: some View {
        VStack {
            NavigationLink(destination: ExportTasksView(),
                           tag: true,
                           selection: $model.navigateToExport) { }
            
            NavigationLink(destination: TaskDetailsView(model: TaskDetailsViewModel(model)),
                           tag: true,
                           selection: $model.navigateToTaskDetails) { }
            
            SearchBar(searchText: $model.searchText, isEditingSearch: $model.isEditingSearch, sortSelection: $model.sortSelection)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: model.sortSelection) { newSortSelection in
                    model.changedTaskSort(sortType: newSortSelection)
                }
            
//            SegmentedPicker(accessibilityText: TasksConstant.pickerAccessibilityText,
//                            categories: model.taskCategories,
//                            selectedCategory: $model.selectedTaskCategory)
//                .padding(.horizontal)
//                .padding(.bottom)
            
            TaskListView(model: TaskListViewModel(model))
                .padding(.horizontal)
        }
        .roundButton(
            color: GlobalConstant.accentColor,
            image: Image(systemName: "plus").foregroundColor(colorScheme == .dark ? .black : .white)) {
            model.tappedNewTask()
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button {
//                    model.tappedExport()
//                } label: {
//                    Label(TasksConstant.exportAccessibilityText, systemImage: TasksConstant.exportButtonIcon)
//                }
//            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    withAnimation {
                        model.tappedLogOut()
                    }
                } label: {
                    Text(GlobalConstant.logoutButtonText)
                }
            }
        }
        .sheet(isPresented: $model.navigateToNewTask) {
            NavigationView {
                NewTaskView(model: NewTaskViewModel(model))
            }
        }
    }
}


/** Data model for the Tasks view. Communicates with Home view's model to
 obtain data and to communicate instructions, such as logging out. */
class TasksHomeViewModel: TaskListParent, ObservableObject {
    
    func refreshTaskList() {
        return
    }
    
    /* MARK: Model fields */
    
    var parentModel: HomeViewModel
    
    // HomeView parent model
    @Published var user: User
    
    // Task list parent protocol
    @Published var taskList: AsyncTaskList
    @Published var selectedTask: Task = Task(creatorID: "")
    
    // Navigation
    @Published var navigateToNewTask: Bool = false
    @Published var navigateToExport: Bool? = false
    @Published var navigateToTaskDetails: Bool? = false
    
    // Segmented control
    @Published var taskCategories: [String] = TasksConstant.taskCategories
    @Published var selectedTaskCategory: Int = TasksConstant.startingTaskCategory
    
    // Banner state fields
    @Published var showBanner: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier
        .BannerData(title: "", detail: "", type: .Info)
    
    // Search bar
    @Published var searchText: String = ""
    @Published var isEditingSearch: Bool = false
    @Published var sortSelection: TaskSort = .none
    
    /* MARK: Model methods */
    
    init(_ parentModel: HomeViewModel) {
        self.user = parentModel.user
        self.taskList = parentModel.user.taskList
        self.parentModel = parentModel
    }
    
    func tappedLogOut() {
        if (!self.parentModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    func tappedExport() {
        self.navigateToExport = true
    }
    
    func tappedNewTask() {
        self.navigateToNewTask = true
    }
    
    func tappedTask() {
        self.navigateToTaskDetails = true
    }
    
    func changedTaskSort(sortType: TaskSort) {
        if sortType == .topological {
            self.taskList.getTopologicalOrdering()
        } else {
            self.taskList.sort(sortType)
        }
        self.objectWillChange.send()
    }
    
    func dismissChildView(_ named: String) {
        switch named {
        case "NewTaskView":
            self.navigateToNewTask = false
        case "ExportTasksView":
            self.navigateToExport = false
        case "TaskDetailsView":
            self.navigateToTaskDetails = false
        default:
            return
        }
    }
    
    /* MARK: Helper methods */
    
//    func refreshTaskList() {
//        self.taskList = AsyncTaskList(parentModel.user.data.tasks)
//    }
    
    func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showBanner = true
    }
    
    func showBannerWithSuccessMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericSuccessBannerTitle
        bannerData.detail = message
        bannerData.type = .Success
        showBanner = true
    }
}

struct TasksHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
