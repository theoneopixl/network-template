//
//  PersonAPIRequester.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

enum PersonAPIRequester: APIRequestBuilder {
    case getPersons
    case getPerson(personID: Int)
    case createPerson(body: PersonDTO)
    case updatePerson(personID: Int, body: PersonDTO)
    case deletePerson(personID: Int)
    case grantAdmin(personID: Int)
}

extension PersonAPIRequester {
    var path: String {
        switch self {
        case .getPersons:
            return NetworkConstant.Path.Person.persons
        case .getPerson(let personID):
            return NetworkConstant.Path.Person.managePerson(personID: personID)
        case .createPerson(_):
            return NetworkConstant.Path.Person.persons
        case .updatePerson(let personID, _):
            return NetworkConstant.Path.Person.managePerson(personID: personID)
        case .deletePerson(let personID):
            return NetworkConstant.Path.Person.managePerson(personID: personID)
        case .grantAdmin(let personID):
            return NetworkConstant.Path.Person.grantAdmin(personID: personID)
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getPersons:           return .GET
        case .getPerson(_):         return .GET
        case .createPerson(_):      return .POST
        case .updatePerson(_, _):   return .PUT
        case .deletePerson(_):      return .DELETE
        case .grantAdmin(_):        return .GET
        }
    }
    
    var parameters: [URLQueryItem]? {
        return nil
    }
    
    var isTokenNeeded: Bool {
        switch self {
        case .getPersons:           return false
        case .getPerson(_):         return false
        case .createPerson(_):      return true
        case .updatePerson(_, _):   return true
        case .deletePerson(_):      return true
        case .grantAdmin(_):        return true
        }
    }
    
    var body: Data? {
        switch self {
        case .createPerson(let body):
            return JSONEncoder.encode(body: body)
        case .updatePerson(_, let body):
            return JSONEncoder.encode(body: body)
        default:
            return nil
        }
    }
}
