//
//  CreateUserMigration.swift
//  
//
//  Created by 张行 on 2022/6/15.
//

import Foundation
import Fluent

/// 新建 User 表迁移
struct CreateUserMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        /// 新增表 user
        /// 新增字段 id username password nike_name create_time update_time
        try await database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .field("nike_name", .string, .required)
            .field("create_time", .datetime)
            .field("update_time", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        /// 回滚就直接删除刚才创建的表
        try await database.schema(User.schema).delete()
    }
}
