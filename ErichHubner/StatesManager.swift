//
//  StateManager.swift
//  ErichHubner
//
//  Created by erich on 27/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import CoreData
class StatesManager {
    
    static let shared = StatesManager()
    var states: [State] = []
    
    func loadStates(with  context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            states  = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteState(index: Int, context: NSManagedObjectContext) {
        let state = states[index]
        context.delete(state)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private init() {
    
    }
}
