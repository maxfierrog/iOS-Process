//
//  LoginView.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            Text("Process!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 45)
            
            TextField("username", text: $username)
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
                Button("Register") {
                    // FIXME: Show RegistrationView()
                }
                .frame(width: 100.0, height: 50.0)
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                Button("Log In") {
                    
                }
                .frame(width: 100.0, height: 50.0)
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
