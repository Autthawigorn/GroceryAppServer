//
//  User.swift
//  GroceryAppServer
//
//  Created by Art Mac M5 on 31/5/2569 BE.
//

import Foundation
import Fluent

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password")
    var password: String

    init() {}

    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}
