//
//  LoginRequestDTO.swift
//  GroceryAppServer
//

import Vapor

struct LoginRequestDTO: Content, Validatable {
    let username: String
    let password: String

    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: !.empty)
    }
}
