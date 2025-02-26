//
//  MockObjects.swift
//  TodosTests
//
//  Created by Vika on 26.02.25.
//
//  Содержит Mock для юнит-тестов: Mock для view, Core Data и сетевого слоя.

import UIKit
import CoreData
import Foundation
@testable import Todos

// MARK: - Mock для View протоколов

class MockTodoDetailView: TodoDetailViewProtocol {
    var didCallDidSaveTodo = false
    var errorMessage: String?
    
    func didSaveTodo() {
        didCallDidSaveTodo = true
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
}

class MockTodosListView: TodosListViewProtocol {
    var todos: [Todos]?
    var errorMessage: String?
    var navigationController: UINavigationController? = UINavigationController()
    
    func showTodos(_ todos: [Todos]) {
        self.todos = todos
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
}

// MARK: - Mock для CoreDataManager

class MockCoreDataManager: CoreDataManagerProtocol {
    
    // in-memory контейнер для тестов
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Todos")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Ошибка загрузки in-memory контейнера: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    var saveContextCalled = false
    
    func saveContext() {
        saveContextCalled = true
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения в MockCoreDataManager: \(error)")
            }
        }
    }
}

// MARK: - Mock для NetworkManager

class MockNetworkManager: NetworkManagerProtocol {
    var shouldReturnError = false
    var todosToReturn: [TodoResponse] = []
    
    func fetchTodos(completion: @escaping (Result<[TodoResponse], Error>) -> Void) {
        if shouldReturnError {
            let error = NSError(domain: "MockNetworkError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка сети"])
            completion(.failure(error))
        } else {
            completion(.success(todosToReturn))
        }
    }
}
