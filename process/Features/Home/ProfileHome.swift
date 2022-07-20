//
//  ProfileHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct ProfileHomeView: View {
    
    @Binding var user: User
    
    var body: some View {
        Text(user.name)
    }
}

struct ProfileHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHomeView(user: .constant(User(name: "Max Fierro", username: "", email: "")))
    }
}
