//
//  LoginController.swift
//  
//
//  Created by 张行 on 2022/6/15.
//

import Foundation
import Vapor
import FluentKit

/// 管理用户登录
struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let loginGroup = routes.response.grouped("login")
        /// 注册 POST /login 路由进行登录
        loginGroup.post(use: login)
    }
    
    func login(_ req: Request) async throws -> AppResponse<String> {
        /// 验证 Content 的参数是否满足条件
        try UserRequestContent.validate(content: req)
        let content = try req.content.decode(UserRequestContent.self)
        guard let user = try await User.query(on: req.db).filter(\.$username == content.username).first() else {
            throw LoginAbort().userNotExit.abort
        }
        guard try await req.password.async.verify(content.password, created: user.password) else {
            throw LoginAbort().passwordError.abort
        }
        /// 生成的 Token 字符串
        let tokenString = [UInt8].random(count: 32).base64String()
        /// 创建 Token 数据库实例
        let token = Token(userId: try user.requireID(), token: tokenString)
        /// 保存 Token 到数据库
        try await token.save(on: req.db)
        /// 设置 Token 失效时间自动执行删除任务
        try await req.queue.dispatch(DeleteTokenJob.self, .
                                     init(tokenId: try token.requireID()),
                                     maxRetryCount: 3,
                                     delayUntil: token.expiredTime)
        /// 用户存在 代表登陆成功
        return .init(success: tokenString)
    }
}

/// 解析登陆接口参数信息
struct UserRequestContent: UserContent {
    /// 用户名
    let username: String
    /// 密码
    let password: String
}


