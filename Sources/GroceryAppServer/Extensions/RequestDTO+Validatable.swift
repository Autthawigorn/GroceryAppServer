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
