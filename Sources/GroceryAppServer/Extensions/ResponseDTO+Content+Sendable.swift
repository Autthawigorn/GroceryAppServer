//
//  ResponseDTO+Content.swift
//  GroceryAppServer
//

import Foundation
import Vapor
import GroceryAppSharedDTO

extension LoginResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}

extension RegisterResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}

extension GroceryCategoryRequestDTO: @retroactive Content, @unchecked @retroactive Sendable {}

extension GroceryCategoryResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {
    // convenience failable init รับ GroceryCategory model โดยตรง
    // init? คือ failable initializer — return nil ถ้า groceryCategory.id ยังเป็น nil (ยังไม่ได้ save)
    init?(_ groceryCategory: GroceryCategory) {
        guard let groceryCategoryId = groceryCategory.id else { return nil }
        self.init(
            id: groceryCategoryId,
            title: groceryCategory.title,
            colorCode: groceryCategory.colorCode)
    }
}

extension GroceryItemResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {
    init?(_ groceryItem: GroceryItem) {
        guard let groceryItemId = groceryItem.id else { return nil }
        self.init(
            id: groceryItemId,
            title: groceryItem.title,
            price: groceryItem.price,
            quantity: groceryItem.quantity)
    }
}
