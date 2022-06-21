//
//  Token.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Fluent

final class Token: Model {
    static var schema: String = "token"
    
    @ID(key: .id)
    var id: UUID?
    
    /// 用户的 Token
    @Field(key: "token")
    var token: String
    
    /// 对应用户的 ID
    @Field(key: "user_id")
    var userId: UUID
    
    /// Token 创建时间
    @Timestamp(key: "create_time", on: .create)
    var createTime: Date?
    
    /// 过期时间
    @Field(key: "expired_time")
    var expiredTime: Date
    
    init() {}
    
    init(userId: UUID, token: String) {
        self.userId = userId
        self.token = token
        /// Token 7天之后过期
        self.expiredTime = Date().addingTimeInterval(7 * 24 * 60 * 60)
    }
}
