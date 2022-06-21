//
//  AdminMiddle.swift
//  
//
//  Created by 张行 on 2022/6/21.
//

import Foundation
import Vapor

/// 保证登录进来的一定是管理员
struct AdminMiddle: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        /// 获取当前登录的用户
        let user = try request.auth.require(User.self)
        guard user.isAdmin else {
            /// 当前用户不是管理员
            throw UserAbort().notAdmin.abort
        }
        /// 当前用户是管理员 允许继续传递
        return try await next.respond(to: request)
    }
}

extension RoutesBuilder {
    /// 生成管理员认证的路由
    var admin: RoutesBuilder {
        self.token.grouped(AdminMiddle())
    }
}
