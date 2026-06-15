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
        
        // /api
        // ต้องแนบ "Authorization: Bearer <token>" มาด้วย ไม่งั้นจะได้ 401 Unauthorized
        let api = routes.grouped("api")
            .grouped(AuthPayload.authenticator(), AuthPayload.guardMiddleware())


        // POST: Saving GroceryCategory
        // /api/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)

        // GET: /api/grocery-categories
        api.get("grocery-categories", use: getGroceryCategoriesByUser)

        // DELETE: /api/grocery-categories/:groceryCategoryId
        api.delete("grocery-categories", ":groceryCategoryId", use: deleteGroceryCategory)
    }

    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {

        // 1. userId มาจาก token เท่านั้น (ไม่รับจาก path/body เพื่อกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

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
    
    
    func getGroceryCategoriesByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        // 1. userId มาจาก token เท่านั้น (ไม่รับจาก path/body เพื่อกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // 2. query DB: (custom query for the Array)
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)  /// filter: เทียบค่า Foreign Key (user_id) ในตารางนี้ กับ userId ของเจ้าของ token
            .all() /// func all() async throws -> [GroceryCategory] ผลลัพท์เป็น Array เสมอ
            .compactMap { GroceryCategoryResponseDTO($0) } ///.compactMap​(): Transform รูปแบบข้อมูล พร้อมกับตัดค่า nil ออก
    }
    
    
    func deleteGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        // userId มาจาก token เท่านั้น (ไม่รับจาก path/body เพื่อกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // groceryCategoryId มาจาก path
        guard let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        try await groceryCategory.delete(on: req.db)
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
        
    }
}
