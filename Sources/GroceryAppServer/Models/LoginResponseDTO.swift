//
//  File.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 1/6/2569 BE.
//

import Foundation
import Vapor

struct LoginResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
    let token: String?
    let userID : UUID
}
