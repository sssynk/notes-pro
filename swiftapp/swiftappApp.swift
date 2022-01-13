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
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "viewer")) // create new window if one doesn't exist
        WindowGroup("Login") { // other scene
            Login().handlesExternalEvents(preferring: Set(arrayLiteral: "login"), allowing: Set(arrayLiteral: "*")) // activate existing window if exists
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "login")) // create new window if one doesn't exist
    }
}

