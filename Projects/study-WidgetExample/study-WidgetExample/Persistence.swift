//
//  Persistence.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/11/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<10 {
            let newPost = Post(context: viewContext)
            newPost.title = "Media \(i + 1)"
            newPost.comment = "Comment \(i + 1)"
            newPost.createdTimestamp = Date.now
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer
    var appGroupContainerURL: URL {
        FileManager.sharedContainerURL()
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "study_WidgetExample")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else if container.persistentStoreDescriptions.first != nil  {
            // 앱 그룹으로 컨테이너 생성
            container.persistentStoreDescriptions.first!.url = appGroupContainerURL.appendingPathComponent("study_WidgetExample.sqlite")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func fetchItems() -> [Item] {
        let viewContext = container.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchOnePost(fileName: String) -> Post? {
        let context = container.viewContext
        let request = NSFetchRequest<Post>(entityName: "Post")
        request.predicate = NSPredicate(format: "fileName == %@", fileName)
        
        do {
            return try context.fetch(request).first
        } catch {
            print(error)
            return nil
        }
    }
}
