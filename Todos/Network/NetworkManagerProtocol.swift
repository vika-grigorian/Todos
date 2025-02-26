//
//  NetworkManagerProtocol.swift
//  Todos
//
//  Created by Vika on 26.02.25.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoResponse], Error>) -> Void)
}

extension NetworkManager: NetworkManagerProtocol {}
