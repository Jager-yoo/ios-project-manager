//
//  TaskStatus.swift
//  ProjectManager
//
//  Created by 예거 on 2022/03/02.
//

import Foundation
import RealmSwift

enum TaskStatus: Int, PersistableEnum {
    
    case todo
    case doing
    case done
    
    var headerTitle: String {
        switch self {
        case .todo:
            return "TODO"
        case .doing:
            return "DOING"
        case .done:
            return "DONE"
        }
    }
}
