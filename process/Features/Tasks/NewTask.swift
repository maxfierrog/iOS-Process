//
//  NewTask.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct NewTaskView: View {
    var body: some View {
        VStack {
            Text("Add new task")
        }
        .navigationTitle("New Task")
    }
}

struct NewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskView()
    }
}
