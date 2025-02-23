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
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        return table
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var countLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
        print("TodosListViewController загружен")
    }
    
    func setupUI() {
        title = "Задачи"
        view.backgroundColor = .systemBackground
        
        // table
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        //add button
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        
        let countLabel = UILabel()
        countLabel.text = "0 задач"
        countLabel.textAlignment = .center
        countLabel.textColor = .label
        countLabel.font = UIFont.systemFont(ofSize: 16)
        countLabel.sizeToFit()
        self.countLabel = countLabel
        let countItem = UIBarButtonItem(customView: countLabel)
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTodo)
        )
        addButton.tintColor = .yellow
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([countItem, flexibleSpace, addButton], animated: false)
        
        //search
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc private func addTodo() {
        presenter?.addNewTodo()
    }
    
    // MARK: - TodosListViewProtocol
    
    func showTodos(_ todos: [Todos]) {
        let oldTodos = self.todos
        let changes = oldTodos.difference(from: todos) { $0.id == $1.id }
        
        self.todos = todos
        
        DispatchQueue.main.async {
            self.countLabel?.text = "\(todos.count) задач"
            self.tableView.reloadData()
        }
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
            tableView.deselectRow(at: indexPath, animated: true)
            
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
