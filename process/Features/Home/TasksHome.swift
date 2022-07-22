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
            Picker(TasksConstant.pickerAccessibilityText, selection: $model.selectedTaskCategory) {
                ForEach(model.taskCategories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            ScrollView(.vertical) {
                LazyVGrid(columns: model.taskListColumn) {
                        ForEach(0...35, id: \.self) { value in
                            Text(String(format: "Task %x", value))
                                .font(.caption)
                                .bold()
                                .frame(minWidth: 356, minHeight: 80)
                                .background(Color(red: 220/256, green: 220/256, blue: 220/256))
                                .cornerRadius(20)
                                .padding(.bottom, 8)
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                                .onTapGesture {
                                    model.tappedTask()
                                }
                        }
                    }
                }
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
    @Published var taskListColumn: [GridItem] = [GridItem(.fixed(30))]
    
    // Segmented control
    @Published var taskCategories: [String] = TasksConstant.taskCategories
    @Published var selectedTaskCategory: Int = TasksConstant.startingTaskCategory
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    // Search bar
    @Published var searchText: String = ""
    
    /* MARK: Model methods */
    
    init(_ parentModel: HomeViewModel) {
        self.homeViewModel = parentModel
        self.user = parentModel.getUser()
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
        HomeView(model: HomeViewModel(SuperViewModel()))
    }
}
