//
//  ProjectsHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct ProjectsHomeView: View {
    
    @Binding var user: User

    var body: some View {
        Text(user.name)
    }
}

struct ProjectsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsHomeView(user: .constant(User(name: "Max Fierro", username: "", email: "")))
    }
}
