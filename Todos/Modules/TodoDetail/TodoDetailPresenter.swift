//
//  TodoDetailPresenter.swift
//  Todos
//
//  Created by Vika on 24.02.25.
//


import Foundation
import CoreData

class TodoDetailPresenter: TodoDetailPresenterProtocol {
    
    weak var view: TodoDetailViewProtocol?
    private let coreDataManager = CoreDataManager.shared
    private var todo: Todos?
    
    init(view: TodoDetailViewProtocol, todo: Todos?) {
        self.view = view
        self.todo = todo
    }
    
    func saveTodo(title: String, description: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = coreDataManager.context
        
        if let existingTodo = todo {
            if trimmedTitle.isEmpty && trimmedDescription.isEmpty {
                context.delete(existingTodo)
            } else {
                existingTodo.todo = trimmedTitle
                existingTodo.descriptionText = trimmedDescription
                existingTodo.date = Date()
            }
        } else {
            if trimmedTitle.isEmpty && trimmedDescription.isEmpty {
                self.view?.didSaveTodo()
                return
            } else {
                let newTodo = Todos(context: context)
                newTodo.id = Int64(Date().timeIntervalSince1970)
                newTodo.todo = trimmedTitle
                newTodo.descriptionText = trimmedDescription
                newTodo.completed = false
                newTodo.userId = 1
                newTodo.date = Date()
            }
        }
        
        do {
            try context.save()
            self.view?.didSaveTodo()
        } catch {
            self.view?.showError("Ошибка при сохранении: \(error.localizedDescription)")
        }
    }
}
