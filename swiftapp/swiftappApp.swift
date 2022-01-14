//
//  swiftappApp.swift
//  swiftapp
//
//  Created by James Wilson on 1/10/22.
//

import SwiftUI

@main
struct swiftappApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(myWindow: nil)
                .navigationTitle("Notes Pro - Login")
        }.commands {
            CommandGroup(replacing: .newItem, addition: { })
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "viewer")) // create new window if one doesn't exist
        WindowGroup("Login") { // other scene
        }.commands {
            CommandGroup(replacing: .newItem, addition: { })
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "login")) // create new window if one doesn't exist
    }
}

