//
//  TodosTableView.swift
//  Todos
//
//  Created by Vika on 23.02.25.
//


import UIKit

class TodosTableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)
        register(TodoCell.self, forCellReuseIdentifier: TodoCell.identifier)
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 80
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
