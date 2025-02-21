//
//  TodoResponse.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import Foundation

struct TodoResponse: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
