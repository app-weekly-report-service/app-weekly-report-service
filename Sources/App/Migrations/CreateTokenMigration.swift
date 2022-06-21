//
//  CreateTokenMigration.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Fluent

struct CreateTokenMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Token.schema)
            .id()
            .field("token", .string, .required)
            .field("user_id", .string, .required)
            .field("create_time", .datetime, .required)
            .field("expired_time", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Token.schema).delete()
    }
}
