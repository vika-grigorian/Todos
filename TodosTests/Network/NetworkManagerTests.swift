//
//  NetworkManagerTests.swift
//  Todos
//
//  Created by Vika on 26.02.25.
//

import XCTest
@testable import Todos

class NetworkManagerTests: XCTestCase {
    
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
    }
    
//MARK: - Проверка успешного получения задач
    func testFetchTodos_Success_ReturnsTodos() {
        let expectation = XCTestExpectation(description: "Успешный запрос")
        
        let testTodo = TodoResponse(id: 1, todo: "Тестовая задача", completed: false, userId: 1)
        mockNetworkManager.shouldReturnError = false
        mockNetworkManager.todosToReturn = [testTodo]
        
        mockNetworkManager.fetchTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 1, "Должна вернуться одна задача")
                XCTAssertEqual(todos.first?.id, 1, "ID задачи должен быть равен 1")
            case .failure(let error):
                XCTFail("Ошибка не ожидалась: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
//MARK: - Тестирование ошибки при получении задач
    
    func testFetchTodos_Failure_ReturnsError() {
        let expectation = XCTestExpectation(description: "Ошибка запроса")
        
        mockNetworkManager.shouldReturnError = true
        
        mockNetworkManager.fetchTodos { result in
            switch result {
            case .success(_):
                XCTFail("Ожидалась ошибка, но получили успех")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Ошибка сети", "Сообщение об ошибке должно соответствовать ожидаемому")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
