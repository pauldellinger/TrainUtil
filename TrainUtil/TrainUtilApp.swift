//
//  TrainUtilApp.swift
//  TrainUtil
//
//  Created by Paul Dellinger on 10/19/21.
//

import SwiftUI

@main
struct TrainUtilApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
