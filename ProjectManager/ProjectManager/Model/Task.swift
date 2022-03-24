//
//  Task.swift
//  ProjectManager
//
//  Created by 예거 on 2022/03/02.
//

import Foundation
import RealmSwift

class Task: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var body: String
    @Persisted var dueDate: Date
    @Persisted var status: TaskStatus = .todo
    
    convenience init(title: String, body: String, dueDate: Date) {
        self.init()
        self.title = title
        self.body = body
        self.dueDate = dueDate
    }
    
    // !!!: 할일 인스턴스 deinit 확인용 코드
    deinit {
        print("🍓 할일 인스턴스 삭제됨!")
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}
