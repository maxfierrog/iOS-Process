//
//  TaskList.swift
//  process
//
//  Created by maxfierro on 8/9/22.
//


import SwiftUI


struct TaskListView: View {
    
    @ObservedObject var model: TaskListViewModel
    
    /* MARK: Task List */
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem()], spacing: 8) {
                ForEach($model.taskList.items.indices, id: \.self) { index in
                    TaskCellView(model: TaskCellViewModel(model.taskList.items[index].task))
                        .onTapGesture {
                            model.tappedTask(model.taskList.items[index].task)
                        }
                }
            }
        }
    }
}


class TaskListViewModel: ObservableObject {
    
    var taskList: AsyncTaskList = AsyncTaskList([])
    var parentModel: TaskListParent
    
    init(_ parentModel: TaskListParent) {
        self.parentModel = parentModel
        self.taskList = parentModel.taskList
    }
    
    func tappedTask(_ task: Task) -> Void {
        self.parentModel.selectedTask = task
        self.parentModel.tappedTask()
    }
}


/** The visual representation of a task. */
struct TaskCellView: View {
    
    @ObservedObject var model: TaskCellViewModel
    
    /* MARK: Task Cell */
    
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
    }
}


/** Task cell view model capable of loading its task asynchronously. */
class TaskCellViewModel: ObservableObject {
        
    @Published var task: Task
        
    init(_ task: Task) {
        self.task = task
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
