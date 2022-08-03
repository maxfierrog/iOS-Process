//
//  SelectSubtasks.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI

struct SelectSubtasksView: View {
    
    @ObservedObject var model: SelectSubtasksViewModel
    
    /* MARK: View declaration */
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

class SelectSubtasksViewModel: ObservableObject {
    
    @Published var task: Task
    @Published var user: User
    
    init(_ model: TaskDetailsViewModel) {
        self.task = model.selectedTask
        self.user = model.user
    }
    
}
