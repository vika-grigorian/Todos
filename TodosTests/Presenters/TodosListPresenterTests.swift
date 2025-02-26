//
//  TodosListPresenterTests.swift
//  Todos
//
//  Created by Vika on 26.02.25.
//

import XCTest
import CoreData
@testable import Todos

class TodosListPresenterTests: XCTestCase {
    
    var presenter: TodosListPresenter!
    var mockView: MockTodosListView!
    var mockNetworkManager: MockNetworkManager!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockView = MockTodosListView()
        mockNetworkManager = MockNetworkManager()
        mockCoreDataManager = MockCoreDataManager()
        presenter = TodosListPresenter(networkManager: mockNetworkManager, coreDataManager: mockCoreDataManager)
        presenter.view = mockView
    }
    
//MARK: - Тестирование загрузки локальных задач, если они существуют
    
    func testViewDidLoad_WhenLocalTodosExist_ShowsLocalTodos() {
        let context = mockCoreDataManager.context
        let todo = Todos(context: context)
        todo.id = 100
        todo.todo = "Локальная задача"
        todo.completed = false
        try? context.save()
        
        presenter.viewDidLoad()
        
        let expectation = XCTestExpectation(description: "View обновлена локальными задачами")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(mockView.todos, "View должна получить список задач")
        XCTAssertEqual(mockView.todos?.count, 1, "В списке должна быть 1 задача")
        XCTAssertEqual(mockView.todos?.first?.id, 100, "ID задачи должен совпадать")
    }
    
//MARK: - Тестирование загрузки задач с API, если локальных нет
    func testViewDidLoad_WhenLocalTodosEmpty_FetchesFromAPI() {

        let fetchRequest: NSFetchRequest<Todos> = Todos.fetchRequest()
        let localTodos = (try? mockCoreDataManager.context.fetch(fetchRequest)) ?? []
        XCTAssertEqual(localTodos.count, 0, "Локальных задач не должно быть")
        
        let testTodo = TodoResponse(id: 1, todo: "API задача", completed: false, userId: 1)
        mockNetworkManager.todosToReturn = [testTodo]
        
        presenter.viewDidLoad()
        
        let expectation = XCTestExpectation(description: "View обновлена задачами из API")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertNotNil(mockView.todos, "View должна получить задачи после загрузки из API")
        XCTAssertGreaterThan(mockView.todos?.count ?? 0, 0, "Список задач не должен быть пустым")
    }
    
    func testSearchTodos_FiltersCorrectly() {
        let context = mockCoreDataManager.context
        let todo1 = Todos(context: context)
        todo1.id = 1
        todo1.todo = "Купить хлеб"
        todo1.completed = false
        
        let todo2 = Todos(context: context)
        todo2.id = 2
        todo2.todo = "Купить молоко"
        todo2.completed = false
        
        try? context.save()
        
        presenter.allTodos = [todo1, todo2]
        
        presenter.searchTodos("хлеб")
        
        XCTAssertEqual(mockView.todos?.count, 1, "Должна быть найдена одна задача")
        XCTAssertEqual(mockView.todos?.first?.todo, "Купить хлеб", "Найденная задача должна быть 'Купить хлеб'")
    }
}
