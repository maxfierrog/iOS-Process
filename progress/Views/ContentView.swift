//
//  ContentView.swift
//  progress
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct ContentView: View {
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            Text("Progress")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
