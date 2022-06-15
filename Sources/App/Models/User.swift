//
//  User.swift
//  
//
//  Created by 张行 on 2022/6/15.
//

import Foundation
import Fluent

/// 用户表
final class User: Model {
    /// 表名称
    static var schema: String = "user"
    /// 数据库主键类型为`UUID`
    typealias IDValue = UUID
    
    /// 数据库主键
    @ID(key: .id)
    var id: UUID?
    
    /// 用户名（工号）
    @Field(key: "username")
    var username: String
    
    /// 密码
    @Field(key: "password")
    var password: String
    
    /// 昵称
    @Field(key: "nike_name")
    var nikeName: String
    
    /// 账号创建时间
    @Timestamp(key: "create_time", on: .create)
    var createTime: Date?
    
    /// 账号最后更新时间
    @Timestamp(key: "update_time", on: .update)
    var updateTime: Date?
    
    /// 默认初始化 必须要实现
    init() {}
    
    /// 初始化
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - nikeName: 昵称
    init(username: String, password: String, nikeName: String? = nil) {
        self.username = username
        self.password = password
        self.nikeName = nikeName ?? username
    }
}
