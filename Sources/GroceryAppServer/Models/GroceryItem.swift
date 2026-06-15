//
//  GroceryItem.swift
//  
//
//  Created by Art's Mac M1 on 6/9/26.
//

import Foundation
import Fluent

final class GroceryItem: Model, @unchecked Sendable  {
    
    static let schema = "grocery_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "quantity")
    var quantity: Int
    
    @Parent(key: "grocery_category_id")
    var groceryCategory: GroceryCategory
    
    init() { }
    
    init(id: UUID? = nil, title: String, price: Double, quantity: Int, groceryCategoryId: UUID) {
        self.id = id
        self.title = title
        self.price = price
        self.quantity = quantity
        self.$groceryCategory.id = groceryCategoryId
    }
    
}
