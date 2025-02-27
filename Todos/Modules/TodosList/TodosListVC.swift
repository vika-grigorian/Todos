//
//  TodosListVC.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import UIKit

class TodosListVC: UIViewController, TodosListViewProtocol {
    
    var presenter: TodosListPresenterProtocol?
    private var todos: [Todos] = []
    private let tableView = TodosTableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let toolbar = TodosToolbar()
    private var countLabel: UILabel?
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter?.viewDidLoad()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = "Задачи"
        
        //search
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        searchController.searchBar.placeholder = "Поиск"
        
        // table
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        // toolbar
        view.addSubview(toolbar)
        toolbar.setAddTarget(self, action: #selector(addTodo))
        
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
        self.todos = todos
        DispatchQueue.main.async {
            self.toolbar.updateCount(todos.count)
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

extension TodosListVC: UITableViewDataSource {
    
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
extension TodosListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    // Контекстное меню
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let todo = todos[indexPath.row]
        
        let editAction = UIAction(title: "Редактировать",
                                  image: UIImage(named: "edit")) { _ in
            self.presenter?.didSelectTodo(todo)
        }
        
        let shareAction = UIAction(title: "Поделиться",
                                   image: UIImage(named: "export")) { _ in
            self.presenter?.shareTodo(todo)
        }
        
        let deleteAction = UIAction(title: "Удалить",
                                    image: UIImage(named: "trash"),
                                    attributes: .destructive) { _ in
            self.presenter?.deleteTodo(todo)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
}

// MARK: - UISearchResultsUpdating

extension TodosListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        presenter?.searchTodos(query)
    }
}

// MARK: - TodoDetailViewControllerDelegate / refresh after saving changes
extension TodosListVC: TodoDetailViewControllerDelegate {
    func didSaveTodo() {
        presenter?.refreshData()
    }
}
