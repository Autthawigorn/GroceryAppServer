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
    func boot(routes: any RoutesBuilder) throws {
        
        // /api/users/:userId
        let api = routes.grouped("api", "users", ":userId")
        
        
        // GET: /api/users/:userId/grocery-categories
        api.get("grocery-categories", use: getGroceryCategoriesByUser)
        
        // POST: Saving GroceryCategory
        // /api/users/:userId/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)

        // DELETE: /api/users/:userId/grocery-categories/:groceryCategoryId
    }
    
    func getGroceryCategoriesByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        // 1. get the userId from the url path
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // 2. query DB: (custom query for the Array)
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)  /// filter: เทียบค่า Foreign Key (user_id) ในตารางนี้ กับ userId ที่ได้มาจาก URL
            .all() /// func all() async throws -> [GroceryCategory] ผลลัพท์เป็น Array เสมอ
            .compactMap { GroceryCategoryResponseDTO($0) } ///.compactMap​(): Transform รูปแบบข้อมูล พร้อมกับตัดค่า nil ออก
    }

    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        // 1. get the userId from the url path
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // 2. validate the request body
        try GroceryCategoryRequestDTO.validate(content: req)

        // 3. decode the request
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)

        // 4. query DB: check if the user exists
        /// .find() เหมือน ใช้ .filter() แบบนี้ User.query(on: req.db).filter(\.$id == userId).first()
        guard try await User.find(userId, on: req.db) != nil else {
            throw Abort(.notFound, reason: "User not found")
        }
     

        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)

        // 5. save the grocery category to the database
        try await groceryCategory.save(on: req.db)

        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }

        // 6. DTO for the response
        return groceryCategoryResponseDTO
    }
}
