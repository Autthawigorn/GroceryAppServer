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

        // 1. validate the request body
        try LoginRequestDTO.validate(content: req)

        // 2. decode the request
        let loginRequestDTO = try req.content.decode(LoginRequestDTO.self)

        // 3. query DB: check if the user exists
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == loginRequestDTO.username)
            .first() else {
                  return LoginResponseDTO(error: true, reason: "Username is not found")
        }

        // 4. verify the password
        let result = try await req.password.async.verify(
            loginRequestDTO.password,  // ① รหัสผ่านที่ user พิมพ์ตอน login (ของจริง)
            created: existingUser.password // ② รหัสผ่านที่เก็บไว้ใน database (ตัวเข้ารหัสแล้ว)
        )

        if !result {
            return LoginResponseDTO(error: true, reason: "Password is incorrect")
        }

        // 5. generate the token and return the response
        let authPlayload = try AuthPayload(subject: .init(value: "Grocery App"), expiration: .init(value: .distantFuture), userID: existingUser.requireID())
        
        return try await LoginResponseDTO(
            error: false,
            token: req.jwt.sign(authPlayload),
            userId: existingUser.requireID())
    }

    func register(req: Request) async throws -> RegisterResponseDTO {
        
        // 1. validate the request body
        try RegisterRequestDTO.validate(content: req)

        // 2. decode the request
        let registerRequestDTO = try req.content.decode(RegisterRequestDTO.self)

        // 3. query DB: check if the user already exists
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == registerRequestDTO.username)
            .first() {
            throw Abort(.badRequest, reason: "User already exists")
        }

        // 4. hash the password
        let hashedPassword = try await req.password.async.hash(registerRequestDTO.password)

        // 5. save the user to the database
        let user = User(username: registerRequestDTO.username, password: hashedPassword)
        try await user.save(on: req.db)

        // 6. generate the token, so the client can be logged in right after register
        let authPayload = try AuthPayload(subject: .init(value: "Grocery App"), expiration: .init(value: .distantFuture), userID: user.requireID())
        
        return try await RegisterResponseDTO(
            error: false,
            token: req.jwt.sign(authPayload),
            userId: user.requireID())
    }

    
}



