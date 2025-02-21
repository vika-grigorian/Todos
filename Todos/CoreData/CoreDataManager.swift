//
//  CoreDataManager.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Todos")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("CoreData load error: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
