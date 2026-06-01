//
//  File.swift
//  GroceryAppServer
//
//  Created by Art Mac M5 on 1/6/2569 BE.
//

import Foundation
import Vapor
import Fluent

// /api/register
// /api/login
final class UserController: RouteCollection, Sendable {
    
    func boot(routes: any RoutesBuilder) throws {
        
        let api = routes.grouped("api")
        // /api/register
        api.post("register", use: register)
    }
    
    func login(req: Request) async throws -> String {
        
        // decode the request
        let user = try req.content.decode(User.self)
        
        // check if user exists in the database
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
            throw Abort(.badRequest)
        }
        
        // validate the password
        let rerult = try await req.password.async.verify(user.password, created: existingUser.password)
        
        if !rerult {
            throw Abort(.unauthorized)
        }
        
        //generate the token and return the user
        
        
        return "OK"
        
    }
    
    func register(req: Request) async throws -> RegisterResponseDTO {
        // validate the user // validations
        try User.validate(content: req)
        
        let user = try req.content.decode(User.self)
        
        // find if the user already exists using the user name
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.badRequest, reason: "User already exists")
        }
        
        // hash the password
        user.password = try await req.password.async.hash(user.password)
        // save the user to data base
        try await user.save(on: req.db)
        
        return RegisterResponseDTO(error: false)
    }

    
}



