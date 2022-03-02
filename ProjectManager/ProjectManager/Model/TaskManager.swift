//
//  TaskManager.swift
//  ProjectManager
//
//  Created by 예거 on 2022/03/02.
//

import Foundation

class TaskManager {
    
    private var tasks = [Task]()
    var todoTasks: [Task] {
        return tasks.filter { $0.status == .todo }
    }
    var doingTasks: [Task] {
        return tasks.filter { $0.status == .doing }
    }
    var doneTasks: [Task] {
        return tasks.filter { $0.status == .done }
    }
    
    func createTask(title: String, body: String, dueDate: Date) {
        tasks.append(Task(title: title, body: body, dueDate: dueDate))
    }
    
    func modifyTask(target: Task, title: String, body: String, dueDate: Date) {
        target.title = title
        target.body = body
        target.dueDate = dueDate.timeIntervalSince1970
    }
    
    func changeTaskStatus(target: Task, to status: TaskStatus) {
        target.status = status
    }
    
    func deleteTask(target: Task) {
        tasks.removeAll(where: { $0 == target })
    }
}
