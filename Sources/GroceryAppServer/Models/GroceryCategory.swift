//
//  GroceryCategory.swift
//  GroceryAppServer
//
//  Created by Art's Mac M1 on 6/9/26.
//

import Foundation
import Fluent

final class GroceryCategory: Model, @unchecked Sendable {
    static let schema = "grocery_categories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "color_code")
    var colorCode: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, title: String, colorCode: String, userId: UUID) {
        self.id = id
        self.title = title
        self.colorCode = colorCode
        self.$user.id = userId //$ หมายถึงการเข้าถึงตัวแปรที่เป็น ParentProperty โดยตรง
        //ใน Swift ใช้ @ แปะไว้บนหัวตัวแปรเพื่อเพิ่มพลังให้มัน และใช้ $ เมื่อต้องการเข้าถึง "ตัวจัดการ" (Wrapper) ที่ซ่อนอยู่ข้างหลัง
    }
}
