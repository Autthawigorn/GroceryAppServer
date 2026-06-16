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

        // routes ทุกอันใน group นี้ต้องแนบ JWT token มาด้วย (Authorization: Bearer <token>)
        // ถ้าไม่มี token หรือ token ผิด → 401 Unauthorized อัตโนมัติ
        let api = routes.grouped("api")
            .grouped(AuthPayload.authenticator(), AuthPayload.guardMiddleware())

        // POST   /api/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)
        // GET    /api/grocery-categories
        api.get("grocery-categories", use: getGroceryCategoriesByUser)
        // DELETE /api/grocery-categories/:groceryCategoryId
        api.delete("grocery-categories", ":groceryCategoryId", use: deleteGroceryCategory)
        // POST   /api/grocery-categories/:groceryCategoryId/grocery-items
        api.post("grocery-categories", ":groceryCategoryId", "grocery-items", use: saveGroceryItem)
        // GET    /api/grocery-categories/:groceryCategoryId/grocery-items
        api.get("grocery-categories", ":groceryCategoryId", "grocery-items", use: getGroceryItemsBy)
        // DELETE /api/grocery-categories/:groceryCategoryId/grocery-items/:groceryItemId
        api.delete("grocery-categories", ":groceryCategoryId", "grocery-items", ":groceryItemId", use: deleteGroceryItem)
    }

    // MARK: - Categories
    /// === POST ===
    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {

        // AUTH: ดึง userId จาก JWT token (ป้องกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // REQ-01: ตรวจสอบ format ของ JSON body ที่ส่งมา
        try GroceryCategoryRequestDTO.validate(content: req)

        // REQ-02: แปลง JSON body → GroceryCategoryRequestDTO
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)

        // DB.READ: ตรวจสอบว่า user มีอยู่จริงใน DB
        // (.find() ค้นหาจาก Primary Key ได้ตรงๆ โดยไม่ต้องเขียน .filter(\.$id == userId))
        guard try await User.find(userId, on: req.db) != nil else {
            throw Abort(.notFound, reason: "User not found")
        }

        // CONSTRUCT: สร้าง GroceryCategory model พร้อมผูก foreign key กับ user
        let groceryCategory = GroceryCategory(
            title: groceryCategoryRequestDTO.title,
            colorCode: groceryCategoryRequestDTO.colorCode,
            userId: userId)

        // DB.WRITE: บันทึกลง DB
        try await groceryCategory.save(on: req.db)

        // RES: แปลงเป็น ResponseDTO แล้ว return json (init? return nil ถ้า id ยังเป็น nil)
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        return groceryCategoryResponseDTO
    }

    /// === GET ===
    func getGroceryCategoriesByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {

        // AUTH: ดึง userId จาก JWT token (ป้องกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // DB.READ + RES: Query เฉพาะ categories ของ user นี้ แล้ว map เป็น ResponseDTO array
        // (.compactMap แปลงพร้อมตัด nil ออก — ป้องกัน category ที่ id เป็น nil หลุดออกมา)
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
            .compactMap { GroceryCategoryResponseDTO($0) }
    }

    /// === DLETE ===
    func deleteGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {

        // AUTH: ดึง userId จาก JWT token (ป้องกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // REQ: ดึง groceryCategoryId จาก URL path parameter
        guard let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // DB.READ: ค้นหา category โดย filter ทั้ง userId และ categoryId
        // (ป้องกัน user คนอื่นลบ category ที่ไม่ใช่ของตัวเอง)
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }

        // DB.WRITE: ลบออกจาก DB
        try await groceryCategory.delete(on: req.db)

        // RES: แปลงเป็น ResponseDTO แล้ว return
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        return groceryCategoryResponseDTO
    }


// MARK: - Items
    /// === POST ===
    func saveGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {

        // AUTH: ดึง userId จาก JWT token (ป้องกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // REQ-01: ดึง groceryCategoryId จาก URL path parameter
        guard let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // REQ-02: ตรวจสอบ format ของ JSON body ที่ส่งมา
        try GroceryItemRequestDTO.validate(content: req)

        // REQ-03: แปลง JSON body → GroceryItemRequestDTO
        let groceryItemRequestDTO = try req.content.decode(GroceryItemRequestDTO.self)

        // DB.READ: ตรวจสอบว่า category มีอยู่จริงและเป็นของ user นี้
        // (filter ทั้ง userId และ categoryId ป้องกัน user อื่นแอบเพิ่ม item ใน category ของคนอื่น)
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound, reason: "Grocery category not found for this user.")
        }

        // CONSTRUCT-01: Unwrap category.id (Fluent ID เป็น Optional จนกว่าจะ save ลง DB)
        guard let categoryId = groceryCategory.id else {
            throw Abort(.internalServerError)
        }

        // CONSTRUCT-02: สร้าง GroceryItem model พร้อมผูก foreign key กับ category
        let groceryItem = GroceryItem(
            title: groceryItemRequestDTO.title,
            price: groceryItemRequestDTO.price,
            quantity: groceryItemRequestDTO.quantity,
            groceryCategoryId: categoryId
        )

        // DB.WRITE: บันทึกลง DB
        try await groceryItem.save(on: req.db)

        // RES: แปลงเป็น ResponseDTO แล้ว return json
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        return groceryItemResponseDTO
    }

    /// === GET ===
    func getGroceryItemsBy(req: Request) async throws -> [GroceryItemResponseDTO] {

        // AUTH: ดึง userId จาก JWT token (ป้องกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // REQ: ดึง groceryCategoryId จาก URL path parameter
        guard let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // DB.READ: ตรวจสอบว่า category มีอยู่จริงและเป็นของ user นี้
        // (ป้องกัน user อื่นดู items ใน category ของคนอื่น)
        guard try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() != nil else {
            throw Abort(.notFound)
        }

        // DB.READ + RES: Query items ทั้งหมดใน category นั้น แล้ว map เป็น ResponseDTO array
        // (.compactMap แปลงพร้อมตัด nil ออก — ป้องกัน item ที่ id เป็น nil หลุดออกมา)
        return try await GroceryItem.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCategoryId)
            .all()
            .compactMap { GroceryItemResponseDTO($0) }
    }

    /// === DLETE ===
    func deleteGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {

        // AUTH: ดึง userId จาก JWT token (ป้องกัน user ปลอมตัวเป็นคนอื่น)
        let userId = try req.auth.require(AuthPayload.self).userID

        // REQ: ดึง groceryCategoryId และ groceryItemId จาก URL path parameters
        guard let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self),
              let groceryItemId = req.parameters.get("groceryItemId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // DB.READ: ตรวจสอบว่า category มีอยู่จริงและเป็นของ user นี้
        // (ป้องกัน user คนอื่นลบ item ใน category ที่ไม่ใช่ของตัวเอง)
        guard try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() != nil else {
            throw Abort(.notFound)
        }

        // DB.READ: ค้นหา item โดย filter ทั้ง itemId และ categoryId ป้องกัน user อื่นลบ item ที่ไม่ใช่ของตัวเอง
        guard let groceryItem = try await GroceryItem.query(on: req.db)
            .filter(\.$id == groceryItemId)
            .filter(\.$groceryCategory.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }

        // DB.WRITE: ลบออกจาก DB
        try await groceryItem.delete(on: req.db)

        // RES: แปลงเป็น ResponseDTO แล้ว return
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        return groceryItemResponseDTO
    }
}
