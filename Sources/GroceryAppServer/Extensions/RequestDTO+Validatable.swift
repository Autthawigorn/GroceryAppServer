//
//  RequestDTO+Validatable.swift
//  GroceryAppServer
//

import Foundation
import Vapor
import GroceryAppSharedDTO

extension GroceryCategoryRequestDTO: @retroactive Validatable {

    public static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty, customFailureDescription: "Title cannot be empty")
        validations.add("colorCode", as: String.self, is: !.empty, customFailureDescription: "Color Code cannot be empty")
    }
}

extension GroceryItemRequestDTO: @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("title", as: String.self, is: !.empty, customFailureDescription: "Title cannot be empty")
        validations.add("price", as: Double.self, is: .range(0...), customFailureDescription: "Price must be 0 or greater")
        validations.add("quantity", as: Int.self, is: .range(1...), customFailureDescription: "Quantity must be at least 1")
    }
    
}
