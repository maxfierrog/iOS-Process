//
//  EditProfileCardView.swift
//  process
//
//  Created by maxfierro on 7/25/22.
//


import SwiftUI


/** View containing fields to edit and save useraname, name, and profile
 picture. */
struct EditProfileCardView: View {
    
    @StateObject var model: ProfileHomeViewModel
    
    /* MARK: Edit profile view */
    
    var body: some View {
        GroupBox {
            VStack {
                TextField(text: $model.editorNameField, prompt: Text("Name")) {
                    Text("Screen name")
                }
                .padding(.bottom, 10)
                .padding(.top, 10)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                TextField(text: $model.editorUsernameField, prompt: Text("Username")) {
                    Text("Screen name")
                }
                .padding(.bottom, 10)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                HStack {
                    Button {
                        withAnimation {
                            model.tappedChooseProfilePicture()
                        }
                    } label: {
                        Text("Choose Profile Picture")
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button {
                        withAnimation {
                            model.saveUserData()
                        }
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(.bordered)
                }
            }
        } label: {
            Label("Edit user profile", systemImage: "square.and.pencil")
        }
        .padding()
    }
}
