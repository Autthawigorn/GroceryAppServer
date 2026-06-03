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
