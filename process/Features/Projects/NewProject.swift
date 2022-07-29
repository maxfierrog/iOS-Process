//
//  NewProject.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct NewProjectView: View {
    
    @ObservedObject var model: NewProjectViewModel
    
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
            
            GroupBox {
                List {
                    Text("Collaborator 1")
                }
                .listStyle(.inset)
            } label: {
                HStack {
                    Text("Collaborators:")
                    Spacer()
                    Button {
                        model.tappedAddCollaborator()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.bordered)
                }
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
    
    // Text fields
    @Published var titleField: String = ""
    @Published var descriptionField: String = ""
    
    // Projects home view parent model
    var projectsHomeViewModel: ProjectsHomeViewModel
    @Published var user: User
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    /* MARK: Methods */
    
    init(_ model: ProjectsHomeViewModel) {
        self.projectsHomeViewModel = model
        self.user = model.user
    }
    
    func tappedSave() {
        let newProject = Project(name: self.titleField,
                                 owner: user,
                                 description: self.descriptionField)
        user.addOwnedProjects([newProject]).pushData { error in
            guard error == nil else {
                self.showBannerWithErrorMessage(error?.localizedDescription)
                return
            }
            APIHandler.pushProjectData(newProject) { error in
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
