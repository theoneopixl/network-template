//
//  PersonRepository.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

final class PersonRepository: ObservableObject {
    static let shared = PersonRepository()
    
    @Published var persons: [PersonDTO] = []
}

// MARK: - C.R.U.D
extension PersonRepository {
    
    @MainActor
    func fetchPersons() async {
        do {
            let persons = try await NetworkService.shared.sendRequest(
                apiBuilder: PersonAPIRequester.getPersons,
                responseModel: [PersonDTO].self,
                withRefreshToken: true
            )
            
            self.persons = persons
        } catch let error {
            let networkError = error.toNetworkError()
            print("⚠️ ERROR \(networkError.errorDescription)")
        }
    }
    
    @MainActor
    func createPerson(body: PersonDTO) async {
        do {
            let person = try await NetworkService.shared.sendRequest(
                apiBuilder: PersonAPIRequester.createPerson(body: body),
                responseModel: PersonDTO.self,
                withRefreshToken: true
            )
            
            self.persons.append(person)
        } catch let error {
            let networkError = error.toNetworkError()
            print("⚠️ ERROR \(networkError.errorDescription)")
        }
    }
    
    @MainActor
    func updatePerson(personID: Int, body: PersonDTO) async {
        do {
            let person = try await NetworkService.shared.sendRequest(
                apiBuilder: PersonAPIRequester.updatePerson(personID: personID, body: body),
                responseModel: PersonDTO.self,
                withRefreshToken: true
            )
        
            if let index = self.persons.firstIndex(where: { $0.id == personID }) {
                self.persons[index].firstName = person.firstName
                self.persons[index].lastName = person.lastName
                self.persons[index].age = person.age
            }
        } catch let error {
            let networkError = error.toNetworkError()
            print("⚠️ ERROR \(networkError.errorDescription)")
        }
    }
    
    @MainActor
    func deletePerson(personID: Int) async {
        do {
            try await NetworkService.shared.sendRequest(
                apiBuilder: PersonAPIRequester.deletePerson(personID: personID),
                withRefreshToken: true
            )
            
            self.persons.removeAll(where: { $0.id == personID })
        } catch let error {
            let networkError = error.toNetworkError()
            print("⚠️ ERROR \(networkError.errorDescription)")
        }
    }
    
}

// MARK: - Extra
extension PersonRepository {
    
    @MainActor
    func fetchPerson(personID: Int) async -> PersonDTO? {
        do {
            return try await NetworkService.shared.sendRequest(
                apiBuilder: PersonAPIRequester.getPerson(personID: personID),
                responseModel: PersonDTO.self,
                withRefreshToken: true
            )
        } catch let error {
            let networkError = error.toNetworkError()
            print("⚠️ ERROR \(networkError.errorDescription)")
            return nil
        }
    }
    
    @MainActor
    func grantAdmin(personID: Int) async {
        do {
            try await NetworkService.shared.sendRequest(
                apiBuilder: PersonAPIRequester.grantAdmin(personID: personID),
                withRefreshToken: true
            )
        } catch let error {
            let networkError = error.toNetworkError()
            print("⚠️ ERROR \(networkError.errorDescription)")
        }
    }
    
}
