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

final class UserController: RouteCollection, Sendable {

    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api")
        // POST /api/register
        api.post("register", use: register)
        // POST /api/login
        api.post("login", use: login)
    }


    func login(req: Request) async throws -> LoginResponseDTO {

        // REQ-01: ตรวจสอบ format ของ JSON body ที่ส่งมา
        try LoginRequestDTO.validate(content: req)

        // REQ-02: แปลง JSON body → LoginRequestDTO
        let loginRequestDTO = try req.content.decode(LoginRequestDTO.self)

        // DB.READ: ค้นหา user จาก username ใน DB
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == loginRequestDTO.username)
            .first() else {
            throw Abort(.unauthorized, reason: "Username or password is incorrect")
        }

        // AUTH: เปรียบเทียบ password ที่พิมพ์มากับ hash ที่เก็บไว้ใน DB
        let result = try await req.password.async.verify(
            loginRequestDTO.password,      // password ที่ user พิมพ์ (plain text)
            created: existingUser.password // password ที่เก็บใน DB (hashed)
        )
        guard result else {
            throw Abort(.unauthorized, reason: "Username or password is incorrect")
        }

        // CONSTRUCT: สร้าง JWT payload (ข้อมูลที่จะฝังอยู่ใน token เช่น userId และวันหมดอายุ)
        let authPayload = try AuthPayload(
            subject: .init(value: "Grocery App"),
            expiration: .init(value: Date().addingTimeInterval(60 * 60 * 24 * 30)), // 30 วัน
            userID: existingUser.requireID()
        )

        // RES: Sign token แล้ว return response
        return try await LoginResponseDTO(
            error: false,
            token: req.jwt.sign(authPayload),
            userId: existingUser.requireID())
    }


    func register(req: Request) async throws -> RegisterResponseDTO {

        // REQ-01: ตรวจสอบ format ของ JSON body ที่ส่งมา
        try RegisterRequestDTO.validate(content: req)

        // REQ-02: แปลง JSON body → RegisterRequestDTO
        let registerRequestDTO = try req.content.decode(RegisterRequestDTO.self)

        // DB.READ: ตรวจสอบว่า username ซ้ำกับในระบบมั้ย
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == registerRequestDTO.username)
            .first() {
            throw Abort(.badRequest, reason: "User already exists")
        }

        // CONSTRUCT-01: Hash password ก่อนเก็บลง DB (ห้ามเก็บ plain text เด็ดขาด)
        let hashedPassword = try await req.password.async.hash(registerRequestDTO.password)

        // CONSTRUCT-02: สร้าง User model
        let user = User(
            username: registerRequestDTO.username,
            password: hashedPassword
        )

        // DB.WRITE: บันทึกลง DB
        try await user.save(on: req.db)

        // CONSTRUCT-03: สร้าง JWT payload เพื่อให้ login ได้ทันทีหลัง register
        let authPayload = try AuthPayload(
            subject: .init(value: "Grocery App"),
            expiration: .init(value: Date().addingTimeInterval(60 * 60 * 24 * 30)), // 30 วัน
            userID: user.requireID()
        )

        // RES: Sign token แล้ว return response
        return try await RegisterResponseDTO(
            error: false,
            token: req.jwt.sign(authPayload),
            userId: user.requireID())
    }
}
