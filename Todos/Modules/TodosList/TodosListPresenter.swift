import Foundation
import CoreData
import UIKit

class TodosListPresenter: TodosListPresenterProtocol {
    weak var view: TodosListViewProtocol?
    private let coreDataManager = CoreDataManager.shared
    private var allTodos: [Todos] = []
    private var filteredTodos: [Todos] = []
    
    private let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    
    func viewDidLoad() {
        DispatchQueue.main.async {
            print("Презентер: viewDidLoad начат")

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
        navigateToDetail(for: todo)
    }
    
    func addNewTodo() {
        navigateToDetail(for: nil)
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
    
    func navigateToDetail(for todo: Todos?) {
//        DispatchQueue.main.async {
//            let detailVC = TodoDetailVC(todo: todo)
//            detailVC.delegate = self.view as? TodoDetailViewControllerDelegate
//            self.view?.navigationController?.pushViewController(detailVC, animated: true)
//        }
        
        DispatchQueue.main.async {
                print("Презентер: переход на детальную страницу для задачи \(todo?.todo ?? "новая задача")")
                let detailVC = TodoDetailVC(todo: todo)
                detailVC.delegate = self.view as? TodoDetailViewControllerDelegate
                if let navController = self.view?.navigationController {
                    print("Презентер: навигационный контроллер найден, выполняем push")
                    navController.pushViewController(detailVC, animated: true)
                } else {
                    print("Презентер: Ошибка — навигационный контроллер не найден")
                }
            }
    }
    
    private func fetchLocalTodos() -> [Todos] {
        let context = coreDataManager.context
        let fetchRequest = Todos.fetchRequest() as NSFetchRequest<Todos>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Ошибка при извлечении из Core Data: \(error)")
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
                print("Ошибка при сохранении в Core Data: \(error)")
            }
        }
    }
}
