//
//  GroceryController.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 9/6/2569 BE.
//

import Foundation
import Vapor
import GroceryAppSharedDTO


final class GroceryController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        
        // /api/users/:userId
        let api = routes.grouped("api", "users", ":userId")
        
        // POST: Saving GroceryCategory
        // /api/users/:userId/grocrey-categories
        api.post("grocery-categories", use: saveGroceryCategory)
        
        func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
            // Get userId
            guard let userId = req.parameters.get("userId", as: UUID.self) else {
                throw Abort(.badRequest)
            }
            
            // DTO for request
            let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
            
            let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)
            
            try await groceryCategory.save(on: req.db)
            
            guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
                throw Abort(.internalServerError)
            }
            
            // DTO for response
            return groceryCategoryResponseDTO
        }
        
        
    }
    
    
}
