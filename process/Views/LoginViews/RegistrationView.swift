//
//  RegistrationView.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI
import FirebaseAuth

struct RegistrationView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    @State var email: String = ""
    
    private func didTapRegister() {
        // FIXME: Ensure credentials are valid, give error otherwise
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
        }
    }
    
    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 45)
            
            TextField("username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .padding(.bottom, 15)
            
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
                Button("Register", action: didTapRegister)
                    .padding()
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .previewInterfaceOrientation(.portrait)
    }
}
