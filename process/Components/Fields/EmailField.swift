//
//  EmailFieldView.swift
//  process
//
//  Created by Maximo Fierro on 7/13/22.
//

import SwiftUI
import ActionButton

struct EmailField: View {
    
    let title: String
    @Binding var text: String
    
    var body: some View {
        TextField(title, text: $text)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
}
