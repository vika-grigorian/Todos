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
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                let data = data
            else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                struct TodosContainer: Decodable {
                    let todos: [TodoResponse]
                }
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
