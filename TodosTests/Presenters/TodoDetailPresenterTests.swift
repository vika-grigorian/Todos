//
//  TodoDetailPresenterTests.swift
//  Todos
//
//  Created by Vika on 26.02.25.
//

import XCTest
import CoreData
@testable import Todos

class TodoDetailPresenterTests: XCTestCase {
    
    var presenter: TodoDetailPresenter!
    var mockView: MockTodoDetailView!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockView = MockTodoDetailView()
        mockCoreDataManager = MockCoreDataManager()
        presenter = TodoDetailPresenter(view: mockView, todo: nil, coreDataManager: mockCoreDataManager)
    }
    
//MARK: - Тестирование сохранения задачи с данными
    
    func testSaveTodo_WithNonEmptyTitleAndDescription_CallsDidSaveTodo() {

        let fetchRequest: NSFetchRequest<Todos> = Todos.fetchRequest()
        let countBefore = (try? mockCoreDataManager.context.fetch(fetchRequest).count) ?? 0
        
        presenter.saveTodo(title: "Тестовая задача", description: "Описание задачи")
        
        XCTAssertTrue(mockView.didCallDidSaveTodo, "Метод didSaveTodo должен быть вызван")
        
        let todos = try? mockCoreDataManager.context.fetch(fetchRequest)
        XCTAssertEqual(todos?.count, countBefore + 1, "Новая задача должна быть создана")
    }
  
//MARK: - Тестирование сохранения задачи с пустыми полями
    
    func testSaveTodo_WithEmptyFields_CallsDidSaveTodoWithoutCreatingTodo() {
        presenter.saveTodo(title: "", description: "")
        XCTAssertTrue(mockView.didCallDidSaveTodo, "Метод didSaveTodo должен быть вызван при пустых значениях")
        
        let fetchRequest: NSFetchRequest<Todos> = Todos.fetchRequest()
        let todos = try? mockCoreDataManager.context.fetch(fetchRequest)
        XCTAssertEqual(todos?.count, 0, "Новых объектов не должно быть создано")
    }
}
