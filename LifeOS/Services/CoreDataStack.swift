//
//  CoreDataStack.swift
//  LifeOS
//
//  Stack centralizado do Core Data utilizado pelo app e widgets.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    let viewContext: NSManagedObjectContext

    /// Caminho do arquivo único de banco de dados (para backup ou migração)
    static var persistentStoreURL: URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("LifeOS", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("LifeOSData.sqlite")
    }

    private init(inMemory: Bool = false) {
        let container = NSPersistentContainer(name: "DataModel")
        let description = container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            description.url = CoreDataStack.persistentStoreURL
        }

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Erro ao carregar Core Data: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.viewContext = container.viewContext
    }
}
