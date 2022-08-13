//
//  ProjectsHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI
import QGrid


/** Allows user to view ongoing and finished projects they created or are
 collaborators in, with the option to navigate to their Details views. */
struct ProjectsHomeView: View {
        
    @StateObject var model: ProjectsHomeViewModel
    @Environment(\.colorScheme) private var colorScheme

    /* MARK: Projects home view */

    var body: some View {
        VStack {
            NavigationLink(destination: NotificationsView(), tag: true, selection: $model.navigateToNotifications) { }
            
            NavigationLink(destination: ProjectDetailsView(model: ProjectDetailsViewModel(model)), tag: true, selection: $model.navigateToProjectDetails) { }
            
            SearchBar(searchText: $model.searchText, isEditingSearch: $model.isEditingSearch, sortSelection: $model.sortSelection)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
//            SegmentedPicker(accessibilityText: ProjectsConstant.pickerAccessibilityText,
//                            categories: model.projectCategories,
//                            selectedCategory: $model.selectedProjectCategory)
//                .padding(.horizontal)
//                .padding(.bottom)
            
            ScrollView {
                LazyVGrid(columns: model.twoColumnGrid, spacing: 8) {
                    ForEach(model.user.projectList) { project in
                        ProjectCellView(model: ProjectCellViewModel(project: project))
                            .onTapGesture {
                                model.selectedProject = project
                                model.navigateToProjectDetails = true
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
        .roundButton(
            color: GlobalConstant.accentColor,
            image: Image(systemName: "plus").foregroundColor(colorScheme == .dark ? .black : .white)) {
            model.tappedNewProject()
        }
        .banner(data: $model.bannerData, show: $model.showBanner)
        .accentColor(GlobalConstant.accentColor)
        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button {
//                    model.tappedNotifications()
//                } label: {
//                    Label(ProjectsConstant.notificationsAccessibilityText, systemImage: ProjectsConstant.notificationsButtonIcon)
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
        .sheet(isPresented: $model.navigateToNewProject) {
            NavigationView<NewProjectView> {
                NewProjectView(model: NewProjectViewModel(self.model))
            }
        }
    }
}


/** Data model for the Projects view. Communicates with Home view's model to
 obtain data and to communicate instructions, such as logging out. */
class ProjectsHomeViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // HomeView parent model
    private var parentModel: HomeViewModel
    @Published var user: User
    
    // Search bar
    @Published var searchText: String = ""
    @Published var isEditingSearch: Bool = false
    @Published var sortSelection: TaskSort = .none
    
    // Navigation
    @Published var navigateToNewProject: Bool = false
    @Published var navigateToProjectDetails: Bool? = false
    @Published var navigateToNotifications: Bool? = false
    @Published var selectedProject: Project = Project(creatorID: "")
    
    // Projects grid
    @Published var twoColumnGrid: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Segmented control
    @Published var projectCategories: [String] = ProjectsConstant.projectCategories
    @Published var selectedProjectCategory: Int = ProjectsConstant.startingProjectCategory
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false

    /* MARK: Model methods */
    
    init(_ parentModel: HomeViewModel) {
        self.parentModel = parentModel
        self.user = parentModel.user
    }
    
    /* MARK: Action methods */
    
    func tappedLogOut() {
        if (!self.parentModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    func tappedNotifications() {
        self.navigateToNotifications = true
    }
    
    func dismissNewProjectView() {
        self.navigateToNewProject = false
    }
    
    func tappedNewProject() {
        self.navigateToNewProject = true
    }
    
    func showProjectDetails(project: Project) {
        self.selectedProject = project
        self.navigateToProjectDetails = true
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


struct ProjectsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
