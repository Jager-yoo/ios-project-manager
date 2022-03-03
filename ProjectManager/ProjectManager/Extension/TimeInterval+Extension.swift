//
//  TimeInterval+Extension.swift
//  ProjectManager
//
//  Created by 예거 on 2022/03/04.
//

import Foundation

extension TimeInterval {
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: self)
        return Self.dateFormatter.string(from: date)
    }
    
    var isOverdue: Bool {
        let currentDate = Date().timeIntervalSince1970
        return self.dateString < currentDate.dateString
    }
}
