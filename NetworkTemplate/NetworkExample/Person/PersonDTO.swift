//
//  PersonDTO.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

final class PersonDTO: Codable, Identifiable, ObservableObject, Equatable, Hashable {
    @Published var id: Int?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var age: Int?
    
    // Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, age
    }
    
    init(id: Int? = nil, firstName: String? = nil, lastName: String? = nil, age: Int? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    // Equatable implementation
    static func == (lhs: PersonDTO, rhs: PersonDTO) -> Bool {
        return lhs.id == rhs.id &&
               lhs.firstName == rhs.firstName &&
               lhs.lastName == rhs.lastName &&
               lhs.age == rhs.age
    }
    
    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(firstName)
        hasher.combine(lastName)
        hasher.combine(age)
    }
    
    // Decodable implementation
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.age = try container.decodeIfPresent(Int.self, forKey: .age)
    }
    
    // Encodable implementation
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(age, forKey: .age)
    }
}

