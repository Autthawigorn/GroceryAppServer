//
//  RegisterRequestDTO.swift
//  GroceryAppServer
//

import Vapor

struct RegisterRequestDTO: Content, Validatable {
    let username: String
    let password: String

    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...10), customFailureDescription: "Password must be 6-10 characters")
    }
}
