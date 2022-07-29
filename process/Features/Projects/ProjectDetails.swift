//
//  ProjectDetails.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct ProjectDetailsView: View {
    
    @ObservedObject var model: ProjectDetailsViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: View declaration */
    
    var body: some View {
        VStack {
            NavigationLink(destination: TaskDetailsView(model: TaskDetailsViewModel(model)), tag: true, selection: $model.navigateToTaskDetails) { }
            
            SearchBar(searchText: $model.searchText, isEditingSearch: $model.isEditingSearch)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            SegmentedPicker(accessibilityText: TasksConstant.pickerAccessibilityText,
                            categories: model.taskCategories,
                            selectedCategory: $model.selectedTaskCategory)
                .padding(.horizontal)
                .padding(.bottom)
            
            ScrollView(.vertical) {
                LazyVGrid(columns: model.taskListColumn, spacing: 8) {
                    ForEach($model.user.data.tasks.indices, id: \.self) { index in
                        TaskCellView(model: TaskCellViewModel(taskID: model.user.data.tasks[index],
                                                              model: model))
                    }
                }
            }
            .padding(.horizontal)
        }
        .roundButton(
            color: GlobalConstant.accentColor,
            image: Image(systemName: "plus").foregroundColor(colorScheme == .dark ? .black : .white)) {
            model.tappedNewTask()
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
        .sheet(isPresented: $model.navigateToNewTask) {
            NavigationView {
                NewTaskView(model: NewTaskViewModel(model))
            }
        }
        .navigationTitle(model.project.data.name)
    }
}

class ProjectDetailsViewModel: ObservableObject, TaskListViewModel {
    
    /* MARK: Model fields */
    
    // Navigation
    @Published var navigateToTaskDetails: Bool? = false
    @Published var navigateToNewTask: Bool = false
    
    // Parent model
    var projectsHomeViewModel: ProjectsHomeViewModel
    @Published var project: Project = Project(creatorID: "")
    @Published var user: User = User()
    
    // Search bar
    @Published var isEditingSearch: Bool = false
    @Published var searchText: String = ""
    
    // Segmented picker
    @Published var taskCategories: [String] = ["New", "WIP", "Done"]
    @Published var selectedTaskCategory: Int = 0
    
    // Task list
    @Published var taskListColumn: [GridItem] = [GridItem()]
    @Published var selectedTask: Task = Task(creatorID: "")
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    /* MARK: Model initializer */
    
    init(_ model: ProjectsHomeViewModel) {
        self.projectsHomeViewModel = model
        self.project = model.selectedProject
        self.user = model.user
    }
    
    /* MARK: Model action methods */
    
    func openTaskDetails(task: Task) {
        self.selectedTask = task
        self.navigateToTaskDetails = true
    }
    
    func tappedNewTask() {
        self.navigateToNewTask = true
    }
    
    func dismissNewTaskView() {
        self.navigateToNewTask = false
    }
    
    /* MARK: Model helper methods */
    
    func showBannerWithSuccessMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericSuccessBannerTitle
        bannerData.detail = message
        bannerData.type = .Success
        showBanner = true
    }
    
    
}

struct ProjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
