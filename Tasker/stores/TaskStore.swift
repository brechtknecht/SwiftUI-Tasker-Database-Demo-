//
//  TaskStore.swift
//  Backstage
//
//  Created by Felix Tesche on 25.05.21.
//

import Foundation
import RealmSwift

final class TaskStore: ObservableObject {
    private var results: Results<TaskDB>
    
    var tasks: [Task] {
        results.map(Task.init)
    }
    
    // Load Items from the Realm Database
    init(realm: Realm) {
        results = realm.objects(TaskDB.self)
    }
    
    
    func findByID (id: Int) -> TaskDB! {
        do {
            return try Realm().object(ofType: TaskDB.self, forPrimaryKey: id)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

// MARK: - CRUD Actions
extension TaskStore {
    func create(task: String) {
        
        objectWillChange.send()
        
        do {
            let realm = try Realm()
            
            let refDB = TaskDB()
            
            let id = UUID().hashValue
            refDB.id = id
            refDB.task = task
            refDB.isDone = false
            
            try realm.write {
                realm.add(refDB)
            }
        } catch let error {
            // Handle error
            print(error.localizedDescription)
        }
    }
    
    func update(taskID: Int, task: String, isDone: Bool) {
        // TODO: Add Realm update code below
        objectWillChange.send()
        
        let task = self.findByID(id: taskID)!
                
        do {
            let realm = try Realm()
            
            try realm.write {
                let updatedTask = TaskDB()
                
                
                updatedTask.id     = task.id
                updatedTask.task   = task.task
                updatedTask.isDone = isDone
                
                realm.add(updatedTask, update: .modified)
            }
            
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func delete(indexSet: IndexSet) {
        objectWillChange.send()
        
        do {
            let realm = try Realm()
            
            indexSet.forEach ({ index in
                try! realm.write {
                    realm.delete(self.results[index])
                }
            })
        } catch let err {
            print(err.localizedDescription)
        }
    }
}

