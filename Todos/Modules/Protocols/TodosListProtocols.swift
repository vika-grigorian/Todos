//
//  TodosListProtocols.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import Foundation

protocol TodosListViewProtocol: AnyObject {
    func showTodos(_ todos: [Todos])
    func showError(_ message: String)
}

protocol TodosListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refreshData()
    func didSelectTodo(_ todo: Todos)
    func addNewTodo()
    func searchTodos(_ query: String)
}
