//
//  ProjectManagerTests.swift
//  ProjectManagerTests
//
//  Created by 예거 on 2022/03/03.
//

import XCTest
@testable import ProjectManager

class ProjectManagerTests: XCTestCase {
    
    var taskManager: TaskManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        taskManager = TaskManager()
        taskManager.createTask(title: "0번 할일", body: "할일 내용0", dueDate: Date())
        taskManager.createTask(title: "1번 할일", body: "할일 내용1", dueDate: Date())
        taskManager.createTask(title: "2번 할일", body: "할일 내용2", dueDate: Date())
        taskManager.createTask(title: "3번 할일", body: "할일 내용3", dueDate: Date())
        taskManager.createTask(title: "4번 할일", body: "할일 내용4", dueDate: Date())
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        taskManager = nil
    }

    func test_Task_인스턴스_5개_생성_검증() {
        let result = taskManager.fetchTasks(in: .todo).count
        XCTAssertEqual(result, 5)
    }
    
    func test_Task_status_변경_검증() {
        let doingTarget = taskManager.fetchTasks(in: .todo).first
        let doneTarget = taskManager.fetchTasks(in: .todo).last
        XCTAssertNoThrow(try taskManager.changeTaskStatus(target: doingTarget, to: .doing))
        XCTAssertNoThrow(try taskManager.changeTaskStatus(target: doneTarget, to: .done))
        XCTAssertTrue(taskManager.fetchTasks(in: .doing).first! == doingTarget)
        XCTAssertTrue(taskManager.fetchTasks(in: .done).first! == doneTarget)
    }
    
    func test_Task_수정_검증() {
        let target = taskManager.fetchTasks(in: .todo).first!
        XCTAssertNoThrow(try taskManager.editTask(target: target, title: "제목 변경", body: "내용 변경", dueDate: Date(timeIntervalSince1970: 1646289747.609154)))
        XCTAssertEqual(target.title, "제목 변경")
        XCTAssertEqual(target.body, "내용 변경")
        XCTAssertEqual(target.dueDate, Date(timeIntervalSince1970: 1646289747.609154))
    }
    
    func test_Task_수정_실패하면_에러throw_검증() {
        weak var target = taskManager.fetchTasks(in: .todo).first
        XCTAssertNoThrow(try taskManager.deleteTask(indexSet: IndexSet(integer: .zero), in: .todo))
        XCTAssertThrowsError(try taskManager.editTask(target: target, title: "제목 변경", body: "내용 변경", dueDate: Date()))
    }

    func test_Task_status_변경_후_삭제_검증() {
        XCTAssertNoThrow(try taskManager.changeTaskStatus(target: taskManager.fetchTasks(in: .todo).last!, to: .done))
        XCTAssertNoThrow(try taskManager.deleteTask(indexSet: IndexSet(integer: .zero), in: .done))
        XCTAssertTrue(taskManager.fetchTasks(in: .done).isEmpty)
    }
    
    func test_Task_status_변경_실패하면_에러throw_검증() {
        weak var target = taskManager.fetchTasks(in: .todo).first
        XCTAssertNoThrow(try taskManager.deleteTask(indexSet: IndexSet(integer: .zero), in: .todo))
        XCTAssertThrowsError(try taskManager.changeTaskStatus(target: target, to: .doing))
    }
    
    func test_Task_생성_후_dueDate_정렬_검증() {
        taskManager.createTask(title: "오래된 할일", body: "1991년 11월 6일에 저장한 할일", dueDate: Date(timeIntervalSince1970: 689400000))
        let target = taskManager.fetchTasks(in: .todo).first!
        XCTAssertTrue(target.dueDate == Date(timeIntervalSince1970: 689400000))
    }
}
