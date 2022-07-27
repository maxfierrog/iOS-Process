//
//  ProjectsHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Allows user to view ongoing and finished projects they created or are
 collaborators in, with the option to navigate to their Details views. */
struct ProjectsHomeView: View {
        
    @StateObject var model: ProjectsHomeViewModel
    @Environment(\.colorScheme) private var colorScheme

    /* MARK: Projects home view */

    var body: some View {
        VStack {
            NavigationLink(destination: NotificationsView(), tag: true, selection: $model.navigateToNotifications) { }
            NavigationLink(destination: ProjectDetailsView(), tag: true, selection: $model.navigateToProjectDetails) { }
            HStack {
                TextField("Search for a project...", text: $model.searchText)
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
            Picker(ProjectsConstant.pickerAccessibilityText, selection: $model.selectedProjectCategory) {
                ForEach(model.projectCategories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            ScrollView {
                LazyVGrid(columns: model.twoColumnGrid, spacing: 8) {
                    ForEach($model.userProjects.indices, id: \.self) { index in
                        GroupBox {
                            HStack {
                                Text(model.userProjects[index].data.description ?? "")
                                    .font(.footnote)
                                Spacer()
                            }
                            .padding(.top, 1)
                            
                            HStack {
                                ProgressView(DateFormatter().string(from: model.userProjects[index].data.dateCreated), value: 50, total: 100)
                                    .progressViewStyle(.linear)
                                    .font(.caption2)
                                Spacer()
                            }
                            .padding(.top, 8)
                        } label: {
                            Text(model.userProjects[index].data.name)
                        }
                        .onTapGesture {
                            model.tappedProject()
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
            model.tappedNewProject()
        }
        .banner(data: $model.bannerData, show: $model.showBanner)
        .accentColor(GlobalConstant.accentColor)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedNotifications()
                } label: {
                    Label(ProjectsConstant.notificationsAccessibilityText, systemImage: ProjectsConstant.notificationsButtonIcon)
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
    private var homeViewModel: HomeViewModel
    @Published var user: User
    
    // Search bar
    @Published var searchText: String = ""
    @Published var isEditingSearch = false
    
    // Navigation
    @Published var navigateToNewProject: Bool = false
    @Published var navigateToProjectDetails: Bool? = false
    @Published var navigateToNotifications: Bool? = false
    
    // Projects grid
    @Published var twoColumnGrid: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Published var userProjects: [Project] = []
    
    // Segmented control
    @Published var projectCategories: [String] = ProjectsConstant.projectCategories
    @Published var selectedProjectCategory: Int = ProjectsConstant.startingProjectCategory
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false

    /* MARK: Model methods */
    
    init(_ homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self.user = homeViewModel.user
        self.userProjects = APIHandler.pullOwnedProjects(homeViewModel.user)
        print(self.userProjects)
    }
    
    func tappedLogOut() {
        if (!self.homeViewModel.logOut()) {
            self.showBannerWithErrorMessage(GlobalConstant.logOutFailedBannerMessage)
        }
    }
    
    func tappedNotifications() {
        self.navigateToNotifications = true
    }
    
    func tappedNewProject() {
        self.navigateToNewProject = true
    }
    
    func tappedProject() {
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
