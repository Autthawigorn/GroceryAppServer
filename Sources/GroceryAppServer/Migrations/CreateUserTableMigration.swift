//
//  CreateUserTableMigration.swift
//  GroceryAppServer
//
//  Created by Art Mac M5 on 31/5/2569 BE.
//

import Foundation
import Fluent

struct CreateUserTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required).unique(on: "username")
            .field("password", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
