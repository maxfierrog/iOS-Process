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
            Picker(ProjectsConstant.pickerAccessibilityText, selection: $model.selectedProjectCategory) {
                ForEach(model.projectCategories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            ScrollView {
                LazyVGrid(columns: model.twoColumnGrid, spacing: 0) {
                    ForEach((0...20), id: \.self) { num in
                        Text("Project \(num)")
                            .font(.caption)
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 180)
                            .background(Color(red: 220/256, green: 220/256, blue: 220/256))
                            .cornerRadius(20)
                            .padding(8)
                    }
                }
            }
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
            NavigationView {
                NewProjectView()
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
    
    // Navigation
    @Published var navigateToNewProject: Bool = false
    @Published var navigateToProjectDetails: Bool? = false
    @Published var navigateToNotifications: Bool? = false
    
    // Projects grid
    @Published var twoColumnGrid: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Segmented control
    @Published var projectCategories: [String] = ProjectsConstant.projectCategories
    @Published var selectedProjectCategory: Int = ProjectsConstant.startingProjectCategory
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    // Search bar
    @Published var searchText: String = ""
    
    /* MARK: Model methods */
    
    init(_ homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self.user = homeViewModel.getUser()
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
        HomeView(model: HomeViewModel(SuperViewModel()))
            .preferredColorScheme(.light)
    }
}
