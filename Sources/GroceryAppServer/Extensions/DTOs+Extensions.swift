//
//  File.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 3/6/2569 BE.
//

import Foundation
import Vapor
import GroceryAppSharedDTO

extension LoginResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}

extension RegisterResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}

extension GroceryCategoryResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {
    
    init?(_ groceryCategory: GroceryCategory) {
        
        guard let id = groceryCategory.id else { return nil }
        
        self.init(id: id, title: groceryCategory.title, colorCode: groceryCategory.colorCode)
        
    }
}
