//
//  File.swift
//  GroceryAppServer
//
//  Created by Art Mac M5 on 31/5/2569 BE.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Content, Validatable, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "passwprd")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: !.empty)
        
        // between 6 and 10 characters
        validations.add("password", as: String.self, is: .count(6...10), customFailureDescription: "Password must be 6-10 characters")
    }
}
