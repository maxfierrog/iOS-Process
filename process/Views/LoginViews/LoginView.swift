//
//  LoginView.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    private func didTapLogin() -> (Void) {
        if (!credentialsInvalid()) {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if (error == nil) {
                    // TODO: Show ProjectsView
                } else {
                    // TODO: Show alert saying why sign in failed
                }
            }
        }
    }
    
    private func credentialsInvalid() -> (Bool) {
        // TODO: Check credentials are valid, and do side effects if they are not
        return false
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Process!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                    .padding(.bottom, 30)
                
                TextField("email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .padding(.bottom, 15)
                
                SecureField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .padding(.bottom, 30)
                
                HStack {
                    NavigationLink(destination: RegistrationView()) {
                        Text("Register")
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Log In", action: didTapLogin)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Login")
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
