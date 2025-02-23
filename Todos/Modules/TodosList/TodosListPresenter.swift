import Foundation
import CoreData

class TodosListPresenter: TodosListPresenterProtocol {
    
    weak var view: TodosListViewProtocol?
    
    private let coreDataManager = CoreDataManager.shared
    private var allTodos: [Todos] = []
    private var filteredTodos: [Todos] = []
    
    //MARK: - Lifecycle
    func viewDidLoad() {
        DispatchQueue.main.async {
            let localTodos = self.fetchLocalTodos()
            if localTodos.isEmpty {
                self.fetchFromAPI()
            } else {
                self.allTodos = localTodos
                self.filteredTodos = localTodos
                self.view?.showTodos(localTodos)
            }
        }
    }
    
    func refreshData() {
        DispatchQueue.main.async {
            self.allTodos = self.fetchLocalTodos()
            self.filteredTodos = self.allTodos
            self.view?.showTodos(self.allTodos)
        }
    }
    
    func didSelectTodo(_ todo: Todos) {
        //TODO: - add open todo, context menu
    }
    
    func addNewTodo() {
        DispatchQueue.main.async {
            let context = self.coreDataManager.context
            let newTodo = Todos(context: context)
            newTodo.id = Int64(Date().timeIntervalSince1970)
            newTodo.todo = "New todo"
            newTodo.completed = false
            newTodo.userId = 1
            newTodo.descriptionText = ""
            
            self.coreDataManager.saveContext()
            self.refreshData()
        }
    }
    
    func deleteTodo(_ todo: Todos) {
        DispatchQueue.main.async {
            let context = self.coreDataManager.context
            context.delete(todo)
            self.coreDataManager.saveContext()
            
            self.allTodos = self.fetchLocalTodos()
            self.filteredTodos = self.allTodos
            self.view?.showTodos(self.allTodos)
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
        let context = coreDataManager.context // Основной контекст
        let fetchRequest = Todos.fetchRequest() as NSFetchRequest<Todos>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching from CoreData: \(error)")
            return []
        }
    }
    
    private func fetchFromAPI() {
        NetworkManager.shared.fetchTodos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todosFromAPI):
                self.saveTodosToCoreData(todosFromAPI)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveTodosToCoreData(_ todos: [TodoResponse]) {
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            for item in todos {
                let newTodo = Todos(context: backgroundContext)
                newTodo.id = Int64(item.id)
                newTodo.todo = item.todo
                newTodo.completed = item.completed
                newTodo.userId = Int64(item.userId)
                newTodo.descriptionText = ""
            }
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    self.refreshData()
                }
            } catch {
                print("Error saving to CoreData: \(error)")
            }
        }
    }
}
