//
//  TasksHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Facilitates a summary of tasks for the user's convencience. */
struct TasksHomeView: View {
    
    @StateObject var model: TasksHomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: Tasks home view */

    var body: some View {
        VStack {
            NavigationLink(destination: ExportTasksView(), tag: true, selection: $model.navigateToExport) { }
            NavigationLink(destination: TaskDetailsView(), tag: true, selection: $model.navigateToTaskDetails) { }
            HStack {
                TextField("Search for a task...", text: $model.searchText)
                        .padding(8)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                         
                                if model.isEditingSearch {
                                    Button(action: {
                                        model.searchText = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                        .onTapGesture {
                            model.isEditingSearch = true
                        }
                if model.isEditingSearch {
                    Button(action: {
                        model.isEditingSearch = false
                        model.searchText = ""
                    }) {
                        Text("Cancel")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            Picker(TasksConstant.pickerAccessibilityText, selection: $model.selectedTaskCategory) {
                ForEach(model.taskCategories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            ScrollView(.vertical) {
                LazyVGrid(columns: model.taskListColumn) {
                    ForEach((0...20), id: \.self) { _ in
                        GroupBox {
                            HStack {
                                Text("Some details")
                                    .font(.footnote)
                            }
                            .padding(.top, 1)
                            
                            HStack {
                                ProgressView("Due Jul 27, 2022", value: 50, total: 100)
                                    .progressViewStyle(.linear)
                                    .font(.caption2)
                            }
                            .padding(.top, 8)
                        } label: {
                            Text("Task Title")
                        }
                        .onTapGesture {

                        }
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .roundButton(
            color: GlobalConstant.accentColor,
            image: Image(systemName: "plus").foregroundColor(colorScheme == .dark ? .black : .white)) {
            model.tappedNewTask()
        }
        .accentColor(GlobalConstant.accentColor)
        .banner(data: $model.bannerData, show: $model.showBanner)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedExport()
                } label: {
                    Label(TasksConstant.exportAccessibilityText, systemImage: TasksConstant.exportButtonIcon)
                }
            }
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
                NewTaskView()
            }
        }
    }
}


/** Data model for the Tasks view. Communicates with Home view's model to
 obtain data and to communicate instructions, such as logging out. */
class TasksHomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // HomeView parent model
    private var homeViewModel: HomeViewModel
    @Published var user: User
    
    // Navigation
    @Published var navigateToNewTask: Bool = false
    @Published var navigateToExport: Bool? = false
    @Published var navigateToTaskDetails: Bool? = false
    
    // Task list
    @Published var taskListColumn: [GridItem] = [GridItem()]
    
    // Segmented control
    @Published var taskCategories: [String] = TasksConstant.taskCategories
    @Published var selectedTaskCategory: Int = TasksConstant.startingTaskCategory
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    // Search bar
    @Published var searchText: String = ""
    @Published var isEditingSearch = false
    
    /* MARK: Model methods */
    
    init(_ parentModel: HomeViewModel) {
        self.homeViewModel = parentModel
        self.user = parentModel.user
    }
    
    func tappedLogOut() {
        if (!self.homeViewModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    func tappedTask() {
        self.navigateToTaskDetails = true
    }
    
    func tappedExport() {
        self.navigateToExport = true
    }
    
    func tappedNewTask() {
        self.navigateToNewTask = true
    }
    
    /* MARK: Helper methods */
    
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
