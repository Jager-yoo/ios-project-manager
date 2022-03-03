//
//  ContentView.swift
//  ProjectManager
//
//  Created by 예거 on 2022/02/28.
//

import SwiftUI
import Firebase

struct ContentView: View {
    let taskManager = TaskManager(tasks: [
        Task(title: "0번 할일", body: "1줄\n2줄\n3줄\n4줄", dueDate: Date()),
        Task(title: "1번 할일", body: "1줄\n2줄\n3줄", dueDate: Date(timeIntervalSinceNow: -86400 * 2)),
        Task(title: "2번 할일", body: "1줄\n2줄", dueDate: Date(timeIntervalSinceNow: -86400)),
        Task(title: "3번 할일", body: "1줄", dueDate: Date(timeIntervalSinceNow: 86400)),
        Task(title: "4번 할일", body: "1줄\n2줄\n3줄\n4줄", dueDate: Date(timeIntervalSinceNow: 86400 * 2))
    ])
    
    var body: some View {
        HStack {
            List {
                ForEach(taskManager.todoTasks) { task in
                    TaskListCellView(task: task)
                }
            }
            List {
                ForEach(taskManager.todoTasks) { task in
                    TaskListCellView(task: task)
                }
            }
            List {
                ForEach(taskManager.todoTasks) { task in
                    TaskListCellView(task: task)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView()
                .previewInterfaceOrientation(.landscapeRight)
        } else {
            ContentView()
        }
    }
}
