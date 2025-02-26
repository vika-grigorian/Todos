//
//  CoreDataManagerProtocol.swift
//  Todos
//
//  Created by Vika on 26.02.25.
//


import CoreData

protocol CoreDataManagerProtocol {
    var context: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func saveContext()
}

extension CoreDataManager: CoreDataManagerProtocol {}
