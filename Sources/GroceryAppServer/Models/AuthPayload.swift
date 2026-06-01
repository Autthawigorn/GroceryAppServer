//
//  File.swift
//  GroceryAppServer
//
//  Created by Autthawigorn MBP on 1/6/2569 BE.
//

import Foundation
import JWTKit

struct AuthPayload: JWTPayload {
    
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userID = "uid"
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userID: UUID
    
    func verify(using signer: some JWTAlgorithm) throws {
        try self.expiration.verifyNotExpired()
    }
}
