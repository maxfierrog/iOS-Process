//
//  RegistrationView.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI
import ActionButton
import FirebaseAuth

enum FocusableRegistrationField: Hashable {
    case emailField, passwordField
}

struct RegistrationView: View {
    
    @State var usernameField: String = ""
    @State var screenNameField: String = ""
    @State var passwordField: String = ""
    @State var emailField: String = ""
    
    @State var registerButtonState: ActionButtonState = .disabled(title: "Please enter all fields", systemImage: "rectangle.and.pencil.and.ellipsis")
    
    @FocusState var focus: FocusableRegistrationField?
    
    private func didTapRegister() {
        // FIXME: Ensure credentials are valid, give error otherwise
        Auth.auth().createUser(withEmail: emailField, password: passwordField) { authResult, error in
            
        }
    }
    
    var body: some View {
        NavigationView {
            GroupBox {
                VStack (alignment: .center, spacing: 10, content: {
                    TextField(text: $usernameField, prompt: Text("Username")) {
                        Text("Username")
                    }
                    .padding(.bottom, 10)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                    TextField(text: $screenNameField, prompt: Text("Screen Name")) {
                        Text("Screen Name")
                    }
                    .padding(.bottom, 10)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                    EmailField(title: "Email", text: $emailField)
                        .padding(.bottom, 10)
                        .submitLabel(.next)
                        .focused($focus, equals: .emailField)
                        .onSubmit {
                            focus = .passwordField
                        }
                    
                    PasswordField(title: "Password", text: $passwordField)
                        .padding(.bottom, 20)
                        .focused($focus, equals: .passwordField)
                        .submitLabel(.go)
                        .onSubmit {
                            didTapRegister()
                        }
                })
                
                ActionButton(state: $registerButtonState, onTap: {
                    didTapRegister()
                }, backgroundColor: .primary)
            } label: {
                Label("We just need a few things...", systemImage: "list.bullet.rectangle.fill")
            }
            .padding()
            .textFieldStyle(.plain)
            .navigationTitle("Register")
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .previewInterfaceOrientation(.portrait)
    }
}
