//
//  UserController.swift
//  GroceryAppServer
//
//  Created by Art Mac M5 on 1/6/2569 BE.
//

import Foundation
import Vapor
import Fluent
import GroceryAppSharedDTO

// /api/register
// /api/login
final class UserController: RouteCollection, Sendable {
    
    func boot(routes: any RoutesBuilder) throws {
        
        let api = routes.grouped("api")
        // /api/register
        api.post("register", use: register)
        
        // /api/login
        api.post("login", use: login)
    }
    
    func login(req: Request) async throws -> LoginResponseDTO {

        // validate the request body
        try LoginRequestDTO.validate(content: req)

        // decode the request
        let loginRequestDTO = try req.content.decode(LoginRequestDTO.self)

        // check if user exists in the database
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == loginRequestDTO.username)
            .first() else {
                  return LoginResponseDTO(error: true, reason: "Username is not found")
        }

        // validate the password
        let result = try await req.password.async.verify(loginRequestDTO.password, created: existingUser.password)

        if !result {
            return LoginResponseDTO(error: true, reason: "Password is incorrect")
        }

        //generate the token and return the user
        let authPlayload = try AuthPayload(subject: .init(value: "Grocery App"), expiration: .init(value: .distantFuture), userID: existingUser.requireID())
        return try await LoginResponseDTO(error: false, token: req.jwt.sign(authPlayload), userId: existingUser.requireID())


    }

    func register(req: Request) async throws -> RegisterResponseDTO {
        // validate the request body
        try RegisterRequestDTO.validate(content: req)

        let registerRequestDTO = try req.content.decode(RegisterRequestDTO.self)

        // find if the user already exists using the user name
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == registerRequestDTO.username)
            .first() {
            throw Abort(.badRequest, reason: "User already exists")
        }

        // hash the password
        let hashedPassword = try await req.password.async.hash(registerRequestDTO.password)

        // save the user to data base
        let user = User(username: registerRequestDTO.username, password: hashedPassword)
        try await user.save(on: req.db)

        return RegisterResponseDTO(error: false)
    }

    
}



