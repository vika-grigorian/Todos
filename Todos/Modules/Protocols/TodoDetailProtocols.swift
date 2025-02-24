//
//  TodoDetailProtocols.swift
//  Todos
//
//  Created by Vika on 24.02.25.
//


import Foundation

protocol TodoDetailViewProtocol: AnyObject {
    func didSaveTodo()
    func showError(_ message: String)
}

protocol TodoDetailPresenterProtocol: AnyObject {
    func saveTodo(title: String, description: String)
}
