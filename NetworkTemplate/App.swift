//
//  NetworkTemplateApp.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import SwiftUI

@main
struct NetworkTemplateApp: App {
    
    // Repositories
    @StateObject private var personRepo: PersonRepository = .shared
    
    // MARK: -
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(personRepo)
                .task {
                    await personRepo.fetchPersons()
                }
        }
    } // End body
} // End struct
