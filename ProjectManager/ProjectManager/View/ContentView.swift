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
        Task(title: "0번 할일0번 할일0번 할일0번 할일0번 할일0번 할일0번 할일0번 할일", body: "1줄텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트\n2줄텍스트텍스트\n3줄텍스트텍스트\n4줄텍스트텍스트", dueDate: Date()),
        Task(title: "1번 할일1번 할일1번 할일1번 할일1번 할일1번 할일1번 할일", body: "1줄텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트텍스트\n2줄텍스트텍스트텍스트\n3줄텍스트텍스트", dueDate: Date(timeIntervalSinceNow: -86400 * 2)),
        Task(title: "2번 할일", body: "1줄텍스트텍스트텍스트텍스트\n2줄텍스트텍스트텍스트텍스트", dueDate: Date(timeIntervalSinceNow: -86400)),
        Task(title: "3번 할일", body: "1줄텍스트텍스트텍스트텍스트텍스트", dueDate: Date(timeIntervalSinceNow: 86400)),
        Task(title: "4번 할일", body: "1줄텍스트\n2줄텍스트텍스트텍스트텍스트\n3줄텍스트텍스트텍스트\n4줄텍스트텍스트텍스트텍스트텍스트", dueDate: Date(timeIntervalSinceNow: 86400 * 2))
    ])
    
    var body: some View {
        HStack {
            TaskListView(tasks: taskManager.todoTasks)
            TaskListView(tasks: taskManager.todoTasks)
            TaskListView(tasks: taskManager.todoTasks)
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
