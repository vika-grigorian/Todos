//
//  NetworkManager.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import Foundation
 
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchTodos(completion: @escaping (Result<[TodoResponse], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let container = try JSONDecoder().decode(TodosContainer.self, from: data)
                completion(.success(container.todos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
