//
//  NewTask.swift
//  process
//
//  Created by maxfierro on 8/9/22.
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
                    Text("Project:  \(model.toProjectName)")
                    
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


class NewTaskViewModel: TaskMeddlerModel, ObservableObject {
    
    /* MARK: Model fields */
    
    // Fields
    @Published var titleField: String = ""
    @Published var descriptionField: String = ""
    @Published var size: Int = 1
    @Published var dateDue: Date = Date()
    @Published var toProject: String? = nil
    @Published var toProjectName: String = "None"
    
    // Projects home view parent model
    var parentModel: TaskListParent
    @Published var user: User
    @Published var editingTask: Task?
    
    // Banner state fields
    @Published var showBanner: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier
        .BannerData(title: "", detail: "", type: .Info)
    
    /* MARK: Model methods */
    
    init(_ model: TaskListParent) {
        self.user = model.user
        self.parentModel = model
    }
    
    func setToProject(_ project: Project) {
        self.toProject = project.data.id
        self.toProjectName = project.data.name
    }
    
    func getDueDateSuggestion() {
        self.dateDue = DueDateUtils.getDueDateEstimate(taskTitle: self.titleField,
                                                       taskDescription: self.descriptionField,
                                                       user: self.user)
    }
    
    func tappedCancel() {
        self.parentModel.dismissChildView("NewTaskView")
    }
    
    func tappedSave() {
        let newTask = Task(creatorID: self.user.data.id)
        
        newTask
            .changeName(self.titleField)
            .changeSize(self.size)
            .changeDescription(self.descriptionField)
            .changeDateDue(self.dateDue)
            .changeAssignee(self.user.data.id)
            .changeProject(self.toProject)
            .finishEdit()
        
        self.user 
            .addTask(newTask)
            .addTaskToMyProject(newTask, nil)
            .finishEdit()
        
        self.dismissView(successBanner: "We have created and saved your new task!")
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
        self.parentModel.dismissChildView("NewTaskView")
        guard successBanner == nil else {
            self.parentModel.showBannerWithSuccessMessage(successBanner)
            return
        }
    }
}
