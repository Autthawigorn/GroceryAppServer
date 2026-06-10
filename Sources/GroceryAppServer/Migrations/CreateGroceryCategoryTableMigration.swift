//
//  File.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 3/6/2569 BE.
//

import Foundation
import Fluent

struct CreateGroceryCategoryTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("grocery_categories")
            .id()
            .field("title", .string, .required)
            .field("color_code", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id")) //ผูก relationship กับ Users
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("grocery_categories")
            .delete()
    }
    
}
