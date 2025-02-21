//
//  TodosListPresenter.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import Foundation
import CoreData

class TodosListPresenter: TodosListPresenterProtocol {
    
    weak var view: TodosListViewProtocol?
    
    private let coreDataManager = CoreDataManager.shared
    private var allTodos: [Todos] = []
    private var filteredTodos: [Todos] = []
    
    private let backgroundQueue = DispatchQueue(label: "com.todoslist.bg", qos: .userInitiated)
    
    //MARK: - Lifecycle
    func viewDidLoad() {
        backgroundQueue.async {
            let localTodos = self.fetchLocalTodos()
            if localTodos.isEmpty {
                self.fetchFromAPI()
            } else {
                self.allTodos = localTodos
                self.filteredTodos = localTodos
                DispatchQueue.main.async {
                    self.view?.showTodos(localTodos)
                }
            }
        }
    }
    
    func refreshData() {
        backgroundQueue.async {
            self.allTodos = self.fetchLocalTodos()
            self.filteredTodos = self.allTodos
            DispatchQueue.main.async {
                self.view?.showTodos(self.allTodos)
            }
        }
    }
    
    func didSelectTodo(_ todo: Todos) {
        //TODO: - add open todo, context menu
    }
    
    func addNewTodo() {
        backgroundQueue.async {
            let context = self.coreDataManager.backgroundContext
            context.perform {
                let newTodo = Todos(context: context)
                newTodo.id = Int64(Date().timeIntervalSince1970)
                newTodo.todo = "New todo"
                newTodo.completed = false
                newTodo.userId = 1
                newTodo.descriptionText = ""
                
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.refreshData()
                    }
                } catch {
                    print("Error saving new todo: \(error)")
                }
            }
        }
    }
    
    func deleteTodo(_ todo: Todos) {
        backgroundQueue.async {
            let context = self.coreDataManager.context
            context.delete(todo)
            self.coreDataManager.saveContext()
            
            self.allTodos = self.fetchLocalTodos()
            self.filteredTodos = self.allTodos
            
            DispatchQueue.main.async {
                self.view?.showTodos(self.allTodos)
            }
        }
    }
    
    func searchTodos(_ query: String) {
        let newFilteredTodos = query.isEmpty ? allTodos : allTodos.filter { $0.todo?.lowercased().contains(query.lowercased()) ?? false }
        
        if filteredTodos != newFilteredTodos {
            filteredTodos = newFilteredTodos
            view?.showTodos(filteredTodos)
        }
    }
    
    private func fetchLocalTodos() -> [Todos] {
        let context = coreDataManager.backgroundContext
        var results: [Todos] = []
        context.performAndWait {
            let fetchRequest = Todos.fetchRequest() as NSFetchRequest<Todos>
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            do {
                results = try context.fetch(fetchRequest)
            } catch {
                print("Error fetching from CoreData: \(error)")
            }
        }
        return results
    }
    
    private func fetchFromAPI() {
        NetworkManager.shared.fetchTodos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todosFromAPI):
                // save in CoreData
                self.saveTodosToCoreData(todosFromAPI)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveTodosToCoreData(_ todos: [TodoResponse]) {
        backgroundQueue.async {
            let context = self.coreDataManager.backgroundContext
            context.perform {
                for item in todos {
                    let newTodo = Todos(context: context)
                    newTodo.id = Int64(item.id)
                    newTodo.todo = item.todo
                    newTodo.completed = item.completed
                    newTodo.userId = Int64(item.userId)
                    newTodo.descriptionText = ""
                }
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.refreshData()
                    }
                } catch {
                    print("Error saving to CoreData: \(error)")
                }
            }
        }
    }
    
}
