//
//  UpdateUserMigration.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import FluentKit

struct UpdateUserMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .field("is_admin", .bool, .sql(.default(false))) /// 默认值是 false
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema)
            .deleteField("is_admin")
            .update()
    }
}
