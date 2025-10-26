//
//  EventureApp.swift
//  Eventure
//
//  Created by Maddy Quinn on 10/16/25.
//

import SwiftUI
import FirebaseCore

@main
struct EventureApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
        WindowGroup {
           
            ContentView()
        }
    }
}
