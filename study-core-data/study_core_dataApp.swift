//
//  study_core_dataApp.swift
//  study-core-data
//
//  Created by Francesco on 06/10/22.
//

import Foundation
import SwiftUI

@main
struct study_core_dataApp: App {
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //.environment(
                //    \.managedObjectContext,
                //     dataController.container.viewContext
                //)
        }
    }
}
