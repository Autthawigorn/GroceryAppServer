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
        // ต้องแนบ "Authorization: Bearer <token>" มาด้วย ไม่งั้นจะได้ 401 Unauthorized
        let api = routes.grouped("api", "users", ":userId")
            .grouped(AuthPayload.authenticator(), AuthPayload.guardMiddleware())


        // POST: Saving GroceryCategory
        // /api/users/:userId/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)
        
        // GET: /api/users/:userId/grocery-categories
        api.get("grocery-categories", use: getGroceryCategoriesByUser)

        // DELETE: /api/users/:userId/grocery-categories/:groceryCategoryId
    }

    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {

        // 1. get the userId from the url path
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // 1.1 เช็คว่า token เป็นของ user คนนี้จริง (กันเอา token ของ user A ไปยิง userId ของ user B)
        try checkUserAuthorization(req: req, userId: userId)

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
        // 1. get the userId from the url path
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // 1.1 เช็คว่า token เป็นของ user คนนี้จริง (กันเอา token ของ user A ไปยิง userId ของ user B)
        try checkUserAuthorization(req: req, userId: userId)

        // 2. query DB: (custom query for the Array)
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)  /// filter: เทียบค่า Foreign Key (user_id) ในตารางนี้ กับ userId ที่ได้มาจาก URL
            .all() /// func all() async throws -> [GroceryCategory] ผลลัพท์เป็น Array เสมอ
            .compactMap { GroceryCategoryResponseDTO($0) } ///.compactMap​(): Transform รูปแบบข้อมูล พร้อมกับตัดค่า nil ออก
    }

    // เทียบ userId ของเจ้าของ token (จาก JWT payload) กับ userId ใน URL ต้องตรงกัน ไม่งั้น 403
    private func checkUserAuthorization(req: Request, userId: UUID) throws {
        let payload = try req.auth.require(AuthPayload.self)
        guard payload.userID == userId else {
            throw Abort(.forbidden, reason: "You are not allowed to access this user's data")
        }
    }
}
