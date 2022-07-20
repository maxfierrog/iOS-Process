//
//  TasksHome.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct TasksHomeView: View {
    
    @Binding var user: User

    var body: some View {
        Text(user.name)
    }
}

struct TasksHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TasksHomeView(user: .constant(User(name: "Max Fierro", username: "", email: "")))
    }
}
