//
//  NewProject.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct NewProjectView: View {
    
    @ObservedObject var model = NewProjectViewModel()
    
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
                        model.tappedSave() // FIXME: dsf
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
                    model.tappedSave()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .accentColor(GlobalConstant.accentColor)
    }
}

class NewProjectViewModel: ObservableObject {
    
    @Published var titleField: String = ""
    @Published var descriptionField: String = ""
    
    func tappedSave() {
        
    }
    
}

struct NewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        NewProjectView()
    }
}
