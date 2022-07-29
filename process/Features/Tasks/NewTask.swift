//
//  NewTask.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct NewTaskView: View {
    
    @ObservedObject var model: NewTaskViewModel
    
    var body: some View {
        VStack {
            GroupBox {
                TextField("Task Title", text: $model.titleField)
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
        .navigationTitle("New Task")
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

class NewTaskViewModel: ObservableObject {
    
    // Fields
    @Published var titleField: String = ""
    @Published var descriptionField: String = ""
    @Published var size: TaskSize = .small // FIXME: !
    @Published var dateDue: Date = Date() // FIXME: !
    @Published var toProject: String? = nil // FIXME: !
    
    // Projects home view parent model
    var parentModel: TaskListViewModel
    @Published var user: User
    
    // Banner state fields
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showBanner: Bool = false
    
    /* MARK: Methods */
    
    init(_ model: TaskListViewModel) {
        self.parentModel = model
        self.user = model.user
    }
    
    func tappedSave() {
        let newTask = Task(creatorID: self.user.data.id)
        
        self.user
            .addTask(newTask.data.id)
            .push { error in
                guard error == nil else {
                    self.showBannerWithErrorMessage(error?.localizedDescription)
                    return
                }
                
                newTask
                    .changeName(self.titleField)
                    .changeSize(self.size)
                    .changeDescription(self.descriptionField)
                    .changeDateDue(self.dateDue)
                    .changeAssignee(self.user.data.id)
                    .changeProject(self.toProject)
                    .push { error in
                        guard error == nil else {
                            self.showBannerWithErrorMessage(error?.localizedDescription)
                            return
                        }
                        self.dismissView(successBanner: "We have created and saved your new task!")
                    }
                }
    }
    
    func tappedCancel() {
        self.parentModel.dismissNewTaskView()
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
        self.parentModel.dismissNewTaskView()
        guard successBanner == nil else {
            self.parentModel.showBannerWithSuccessMessage(successBanner)
            return
        }
    }
}

struct NewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
