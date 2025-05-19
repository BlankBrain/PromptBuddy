//
//  PromptBuddyApp.swift
//  PromptBuddy
//
//  Created by Md. Mehedi Hasan on 18/5/25.
//

import SwiftUI
import CoreData

@main
struct PromptBuddyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext as NSManagedObjectContext)
        }
    }
}
