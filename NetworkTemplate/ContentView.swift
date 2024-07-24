//
//  ContentView.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    // EnvironmentObject
    @EnvironmentObject private var personRepo: PersonRepository
    
    // MARK: -
    var body: some View {
        NavigationStack {
            List(personRepo.persons) { person in
                Text("\(person.firstName ?? "") \(person.lastName ?? "") \(person.age ?? 0)")
            }
        }
    } // End body
} // End struct

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(PersonRepository())
}
