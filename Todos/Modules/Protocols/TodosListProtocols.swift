//
//  TodosListProtocols.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import Foundation
import UIKit

protocol TodosListViewProtocol: AnyObject {
    func showTodos(_ todos: [Todos])
    func showError(_ message: String)
    var navigationController: UINavigationController? { get }
}

protocol TodosListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refreshData()
    func didSelectTodo(_ todo: Todos)
    func addNewTodo()
    func shareTodo(_ todo: Todos)
    func deleteTodo(_ todo: Todos)
    func searchTodos(_ query: String)
    func navigateToDetail(for todo: Todos?)
}
