//
//  MyAIAssistantApp.swift
//  MyAIAssistant
//
//  Created by Snehal Chavan on 7/11/25.
//

import SwiftUI

@main
struct MyAIAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            
            // creating conditional mapping for the different OS and the app view size configuration
            #if os( macOS)
                .frame(width: 400, height: 400)
                    #endif
        }
        
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)  // limiting the resizing option for the app window
        
        #elseif os(visionOs)
        .defaultSize(width: 0.4, height: 0.4, depth: 0.0, in: .meters) // limiting size according to the elemetric window
        .windowResizability(.contentSize)
        
        #endif
    }
}
