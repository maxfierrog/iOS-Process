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
            Picker(TasksConstant.pickerAccessibilityText, selection: $model.selectedTaskCategory) {
                ForEach(model.taskCategories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
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
    }
}


/** Data model for the Tasks view. Communicates with Home view's model to
 obtain data and to communicate instructions, such as logging out. */
class TasksHomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // HomeView parent model
    private var homeViewModel: HomeViewModel
    @Published var user: User
    
    // Segmented control
    @Published var taskCategories: [String] = TasksConstant.taskCategories
    @Published var selectedTaskCategory: Int = TasksConstant.startingTaskCategory
    
    // UI state fields
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
    
    func tappedExport() {
        // FIXME: Show export view
    }
    
    func tappedNewTask() {
        // FIXME: Generate new tasks
    }
    
    /* MARK: Model helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        self.homeViewModel.showBannerWithErrorMessage(message)
    }
    
}

struct TasksHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(SuperViewModel()))
    }
}
