//
//  PasswordField.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import SwiftUI

struct PasswordField: View {
    
    let title: String
    @Binding var text: String
    @State private var isHidden: Bool = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isHidden {
                SecureField(title, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            } else {
                TextField(title, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
            Button {
                isHidden.toggle()
            } label: {
                Image(systemName: isHidden ? "eye.slash" : "eye")
            }
            .foregroundColor(.primary)
        }
        .frame(height: 18)
    }
}
