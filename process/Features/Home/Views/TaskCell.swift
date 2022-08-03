//
//  TaskCell.swift
//  process
//
//  Created by maxfierro on 7/27/22.
//


import SwiftUI


struct TaskCellView: View {
    
    @ObservedObject var model: TaskCellViewModel
    
    var body: some View {
        GroupBox {
            HStack {
                Text(model.formattedDescription())
                    .font(.footnote)
                Spacer()
            }
            .padding(.top, 1)
            HStack {
                Text(model.formattedDueDate())
                    .font(.caption2)
                Spacer()
                Text(String(model.task.data.size))
                    .font(.caption2)
            }
            .padding(.top, 8)
        } label: {
            Text(model.task.data.name)
        }
        .onTapGesture {
            model.tappedTask()
        }
    }
}


class TaskCellViewModel: ObservableObject {
    
    var parentModel: TaskListViewModel
    @Published var task: Task = Task(creatorID: "")
    @Published var navigateToTaskDetails: Bool? = false
    
    init(taskID: String, model: TaskListViewModel) {
        self.parentModel = model
        Task.pull(taskID) { task, error in
            guard error == nil else { return }
            self.task = task!
        }
    }
    
    init(task: Task, model: TaskListViewModel) {
        self.parentModel = model
        self.task = task
    }
    
    func tappedTask() {
        self.parentModel.openTaskDetails(task: self.task)
    }
    
    func formattedDescription() -> String {
        var description: String = task.data.description ?? ""
        if description.count > 100 {
            description = String((description).prefix(100)) + "..."
        }
        return description
    }
    
    func formattedDueDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "PST")! as TimeZone
        return "Due " + dateFormatter.string(from: task.data.dateDue)
    }
    
}


struct TaskCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel(RootViewModel()))
    }
}
