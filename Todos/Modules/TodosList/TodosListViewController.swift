//
//  TodosListViewController.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import UIKit

class TodosListViewController: UIViewController, TodosListViewProtocol {
    
    var presenter: TodosListPresenterProtocol?
    
    private var todos: [Todos] = []
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter?.viewDidLoad()
        print("TodosListViewController загружен")

    }
    
    func setupUI() {
        title = "Задачи"
        view.backgroundColor = .systemBackground
        
        // table
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        //add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodo))
        
        //search
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
    }
    
    @objc private func addTodo() {
        presenter?.addNewTodo()
    }
    
    // MARK: - TodosListViewProtocol
    
    func showTodos(_ todos: [Todos]) {
        let oldTodos = self.todos
        let changes = oldTodos.difference(from: todos) { $0.id == $1.id }
        
        self.todos = todos
        
        tableView.performBatchUpdates({
            for change in changes {
                switch change {
                case .remove(let offset, _, _):
                    tableView.deleteRows(at: [IndexPath(row: offset, section: 0)], with: .fade)
                case .insert(let offset, _, _):
                    tableView.insertRows(at: [IndexPath(row: offset, section: 0)], with: .fade)
                }
            }
        })
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension TodosListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.identifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        let todo = todos[indexPath.row]
        cell.configure(with: todo)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TodosListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let todo = todos[indexPath.row]
        presenter?.didSelectTodo(todo)
    }
    
    // Удаление задачи
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let todo = todos[indexPath.row]
            presenter?.deleteTodo(todo)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension TodosListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        presenter?.searchTodos(query)
    }
}
