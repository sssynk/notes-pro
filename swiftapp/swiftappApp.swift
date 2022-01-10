//
//  swiftappApp.swift
//  swiftapp
//
//  Created by James Wilson on 1/10/22.
//

import SwiftUI

@main
struct swiftappApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            "name": "James Wilson",
            "highScore": 10
        ])
        

        if let url = URL(string: "https://api.james.baby/school/getcurrentalerts") {
            do {
                let contents = try String(contentsOf: url)
                print(contents)
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }

    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

