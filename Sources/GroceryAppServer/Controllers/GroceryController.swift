//
//  GroceryController.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 9/6/2569 BE.
//

import Foundation
import Vapor
import Fluent
import GroceryAppSharedDTO


final class GroceryController: RouteCollection, Sendable {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        
        // /api/users/:userId
        let api = routes.grouped("api", "users", ":userId")
        
        // POST: Saving GroceryCategory
        // /api/users/:userId/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)
    }

    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        // get the userId
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // ตรวจสอบว่ามี user คนนี้อยู่จริงหรือไม่
        guard try await User.find(userId, on: req.db) != nil else {
            throw Abort(.notFound, reason: "User not found")
        }

        // validate the request body
        try GroceryCategoryRequestDTO.validate(content: req)

        // DTO for the request
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)

        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)

        try await groceryCategory.save(on: req.db)

        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }

        // DTO for the response
        return groceryCategoryResponseDTO
    }
}
