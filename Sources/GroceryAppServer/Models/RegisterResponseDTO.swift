//
//  File.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 1/6/2569 BE.
//

import Foundation
import Vapor

struct RegisterResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
}
