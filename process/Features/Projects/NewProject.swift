//
//  NewProject.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


/** Screen enabling users to create a new project by specifing parameters such
 as a name, description, and title. */
struct NewProjectView: View {
    
    @ObservedObject var model: NewProjectViewModel
    
    /* MARK: View declaration */
    
    var body: some View {
        VStack {
            GroupBox {
                TextField("Project Title", text: $model.titleField)
                    .disableAutocorrection(true)
                    .autocapitalization(.sentences)
                    .font(.title2.bold())
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)
            GroupBox {
                TextEditor(text: $model.descriptionField)
                    .disableAutocorrection(true)
                    .autocapitalization(.sentences)
            } label: {
                Text("Description:")
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)
            Spacer()
        }
        .navigationTitle("New Project")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    model.tappedSave()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.bordered)
            }
            
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    model.tappedCancel()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .accentColor(GlobalConstant.accentColor)
    }
}


class NewProjectViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // Text fields
    @Published var titleField: String = ""
    @Published var descriptionField: String = ""
    
    // Projects home view parent model
    var projectsHomeViewModel: ProjectsHomeViewModel
    @Published var user: User
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    /* MARK: Model methods */
    
    init(_ model: ProjectsHomeViewModel) {
        self.projectsHomeViewModel = model
        self.user = model.user
    }
    
    func tappedSave() {
        let newProject = Project(creatorID: self.user.data.id)
        
        self.user
            .addOwnedProject(newProject.data.id)
            .push { error in
                guard error == nil else {
                    self.showBannerWithErrorMessage(error?.localizedDescription)
                    return
                }
                
                newProject
                    .changeName(self.titleField)
                    .changeOwner(self.user.data.id)
                    .changeDescription(self.descriptionField)
                    .addCollaborator(self.user.data.id)
                    .push { error in
                        guard error == nil else {
                            self.showBannerWithErrorMessage(error?.localizedDescription)
                            return
                        }
                        self.dismissView(successBanner: "We have created and saved your new project!")
                    }
            }
    }
    
    func tappedCancel() {
        self.projectsHomeViewModel.dismissNewProjectView()
    }
    
    func tappedAddCollaborator() {
        // FIXME: Implement adding collaborators
    }
    
    /* MARK: Helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = GlobalConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showBanner = true
    }
    
    private func dismissView(successBanner: String?) {
        self.projectsHomeViewModel.dismissNewProjectView()
        guard successBanner == nil else {
            self.projectsHomeViewModel.showBannerWithSuccessMessage(successBanner)
            return
        }
    }
}


struct NewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
