//
//  CreateArticlesMigration.swift
//  
//
//  Created by 张行 on 2022/6/22.
//

import Foundation
import FluentKit

/// 新建表 articles
struct CreateArticlesMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Articles.schema)
            .id()
            .field("user_id", .uuid, .required)
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("create_time", .datetime, .required)
            .field("update_time", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Articles.schema).delete()
    }
}
