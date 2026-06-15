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
    // return Optional เพราะ groceryCategory.id อาจเป็น nil
    // init? คือ failable initializer
    // Fluent Model — id เป็น Optional เพราะยังไม่ได้ save ลง DB @ID(key: .id) var id: UUID?
    
    init?(_ groceryCategory: GroceryCategory) {

        guard let groceryCategoryId = groceryCategory.id else { return nil } // ถ้าเงื่อนไขไม่ผ่าน return nil ได้

        self.init(
            id: groceryCategoryId,
            title: groceryCategory.title,
            colorCode: groceryCategory.colorCode)

    }
}

extension GroceryItemResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {
    // convenience failable init รับ GroceryItem model โดยตรง
    // init? คือ failable initializer
    init?(_ groceryItem: GroceryItem) {
        
        guard let groceryItemId = groceryItem.id else { return nil }
        
        self.init(
            id: groceryItemId,
            title: groceryItem.title,
            price: groceryItem.price,
            quantity: groceryItem.quantity)
    }
}
