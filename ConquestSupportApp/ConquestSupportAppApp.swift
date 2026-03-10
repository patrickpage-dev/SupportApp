//
//  ConquestSupportAppApp.swift
//  ConquestSupportApp
//
//  Created by Patrick Page on 2/3/26.
//

import SwiftUI

@main
struct ConquestSupportAppApp: App {
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}
