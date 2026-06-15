//
//  CreateGroceryItemTableMigration.swift
//
//
//  Created by Art Mac M5 on 31/5/2569 BE.
//

import Foundation
import Fluent

final class CreateGroceryItemTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("grocery_items")
            .id()
            .field("title", .string, .required)
            .field("price", .double, .required)
            .field("quantity", .int, .required)
            .field("grocery_category_id", .uuid, .required, .references("grocery_categories", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("grocery_items")
                   .delete()
    }
    
}
