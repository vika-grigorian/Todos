//
//  CoreDataManagerTests.swift
//  Todos
//
//  Created by Vika on 26.02.25.
//

import XCTest
import CoreData
@testable import Todos

class CoreDataManagerTests: XCTestCase {
    
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockCoreDataManager = MockCoreDataManager()
    }
    
//MARK: - сохранение задачи в CoreData и её извлечение

    func testSaveContext_AddTodoAndFetch_ReturnsSavedTodo() {
        let context = mockCoreDataManager.context
        
        let todo = Todos(context: context)
        todo.id = 123
        todo.todo = "Тестовая задача"
        todo.completed = false
        
        mockCoreDataManager.saveContext()
        
        let fetchRequest: NSFetchRequest<Todos> = Todos.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "В базе должен быть один объект")
            XCTAssertEqual(results.first?.id, 123, "ID задачи должен быть равен 123")
        } catch {
            XCTFail("Ошибка выборки: \(error)")
        }
    }
    
//MARK: - удаление задачи из CoreData и проверка, что объект не в базе

    func testDeleteTodo_RemovesTodoFromContext() {
        let context = mockCoreDataManager.context
        
        let todo = Todos(context: context)
        todo.id = 456
        todo.todo = "Задача для удаления"
        todo.completed = false
        mockCoreDataManager.saveContext()
        
        context.delete(todo)
        mockCoreDataManager.saveContext()
        
        let fetchRequest: NSFetchRequest<Todos> = Todos.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 0, "После удаления база должна быть пустой")
        } catch {
            XCTFail("Ошибка выборки после удаления: \(error)")
        }
    }
}
