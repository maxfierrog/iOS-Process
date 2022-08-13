//
//  NewTask.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//


import SwiftUI


protocol TaskMeddlerModel {
    func tappedCancel() -> Void
    func tappedSave() -> Void
    func getDueDateSuggestion() -> Void
    func setToProject(_ project: Project) -> Void
}


/** Screen where users either create a new task or edit an existing one,
 depending on parameters passed in the view constructor. */
struct EditTaskView: View {
    
    @ObservedObject var model: EditTaskViewModel
    
    /* MARK: View declaration */
    
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
                TextField("", text: $model.descriptionField)
                    .disableAutocorrection(true)
                    .autocapitalization(.sentences)
                    .font(.body)
                    .padding(.top, 4)
            } label: {
                Text("Description:")
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)
            
            GroupBox {
                HStack {
                    Spacer()
                    Text("Choose size:")
                    GroupBox {
                        Picker("Size", selection: $model.size) {
                            Text("Small").tag(1)
                            Text("Medium").tag(2)
                            Text("Large").tag(3)
                        }
                        .pickerStyle(.menu)
                    }
                    Spacer()
                }
            }
            .padding()
            
            GroupBox {
                HStack {
                    DatePicker(
                    "Due Date:",
                    selection: $model.dateDue,
                    displayedComponents: [.date]
                    )
                    
                    Button {
                        model.getDueDateSuggestion()
                    } label: {
                        Image(systemName: "wand.and.stars")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            GroupBox {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(model.user.projectList) { project in
                            ProjectsListItemView(model: ProjectPickerViewModel(project: project, model: model))
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Switch to:  \(model.toProjectName)")
                    
                    Spacer()
                    
                    Button {
                        model.toProject = nil
                        model.toProjectName = "None"
                    } label: {
                        Text("None")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Button {
                    model.tappedDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .padding()
                
                Button {
                    model.tappedComplete()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .foregroundColor(.green)
                }
                .padding()
            }

            Spacer()
        }
        .navigationTitle(model.task.data.name)
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


/** Contains references to the user viewing the task and to the parent model
 for context. */
class EditTaskViewModel: TaskMeddlerModel, ObservableObject {
    
    /* MARK: Model fields */
    
    var parentModel: TaskDetailsViewModel
    
    // Task information
    @Published var titleField: String
    @Published var descriptionField: String
    @Published var size: Int
    @Published var dateDue: Date
    @Published var toProject: String?
    @Published var toProjectName: String = "None"
    
    // Fields
    @Published var user: User
    @Published var task: Task
    
    // Banner state fields
    @Published var showBanner: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier
        .BannerData(title: "", detail: "", type: .Info)
    
    /* MARK: Model methods */
    
    init(_ model: TaskDetailsViewModel) {
        self.user = model.user
        self.parentModel = model
        self.task = model.thisTask
        self.titleField = model.thisTask.data.name
        self.descriptionField = model.thisTask.data.description ?? ""
        self.size = model.thisTask.data.size
        self.toProject = model.thisTask.data.project
        self.dateDue = model.thisTask.data.dateDue
    }
    
    func tappedSave() {
        var fromProject: String? = self.task.data.project
        
        self.task
            .changeName(self.titleField)
            .changeSize(self.size)
            .changeDescription(self.descriptionField)
            .changeDateDue(self.dateDue)
            .changeAssignee(self.user.data.id)
            .changeProject(self.toProject)
            .finishEdit()
        
        self.user
            .addTaskToMyProject(self.task, fromProject)
            .finishEdit()
        
        self.dismissView(successBanner: "We have saved your task!")
    }
    
    func getDueDateSuggestion() {
        self.dateDue = DueDateUtils.getDueDateEstimate(taskTitle: self.titleField,
                                                       taskDescription: self.descriptionField,
                                                       user: self.user)
    }
    
    func tappedCancel() {
        self.parentModel.dismissChildView("EditTaskView")
    }
    
    func setToProject(_ project: Project) {
        self.toProject = project.data.id
        self.toProjectName = project.data.name
    }
    
    func tappedDelete() {
        self.task.delete() { error in
            guard error == nil else {
                self.showBannerWithErrorMessage(error?.localizedDescription)
                return
            }
            self.user
                .removeTask(self.task.data.id)
                .push { error in
                guard error == nil else {
                    self.showBannerWithErrorMessage(error?.localizedDescription)
                    return
                }
                self.parentModel.dismissChildView("EditTaskView")
                self.parentModel.parentModel.dismissChildView("TaskDetailsView")
                self.parentModel.parentModel.showBannerWithSuccessMessage("We have erased your task from existence.")
            }
        }
    }
    
    func tappedComplete() {
        let task1 = self.task
        task1
            .complete()
            .finishEdit()
        self.user
            .removeTask(self.task.data.id)
            .addTask(task1)
            .push { error in
            guard error == nil else {
                self.showBannerWithErrorMessage(error?.localizedDescription)
                return
            }
            self.parentModel.dismissChildView("EditTaskView")
            self.parentModel.parentModel.dismissChildView("TaskDetailsView")
            self.parentModel.parentModel.showBannerWithSuccessMessage("We have erased your task from existence.")
        }
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
        self.parentModel.dismissChildView("EditTaskView")
        guard successBanner == nil else {
            self.parentModel.showBannerWithSuccessMessage(successBanner)
            return
        }
    }
}
