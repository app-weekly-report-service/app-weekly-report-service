//
//  TokenAuthenticator.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Vapor
import FluentKit

/// 验证 Token 授权的中间件
struct TokenAuthenticator : AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        /// 获取请求的 Token
        let tokenString = bearer.token
        /// 根据请求的 Token 获取数据库的 Token 对象
        guard let token = try await Token.query(on: request.db).filter(\.$token == tokenString).first() else {
            /// 如果查询不出来 那就是一个无效的 Token
            throw TokenAbort().invalid.abort
        }
        guard token.expiredTime >= Date() else {
            /// 当前时间已经大于 Token 过期时间
            throw TokenAbort().expired.abort
        }
        /// 代表 Token 依然可用， 查询出关联的 User 对象
        guard let user = try await User.find(token.userId, on: request.db) else {
            /// 如果查询不到 代表 Token 关联的用户已经删除 或者存的时候存错了
            throw UserAbort().notExit(token.userId).abort
        }
        /// 将当前的用户进行登录
        request.auth.login(user)
    }
}

extension RoutesBuilder {
    /// 返回 TokenAuthenticator 授权之后的路由
    var token: RoutesBuilder {
        self.grouped(TokenAuthenticator())
    }
}
