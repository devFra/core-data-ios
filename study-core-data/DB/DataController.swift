//
//  DataController.swift
//  study-core-data
//
//  Created by Francesco on 06/10/22.
//

import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "rsidatamodel")
    
    init(){
        container.loadPersistentStores { description, error in
            if let error = error {
                print ("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
}

