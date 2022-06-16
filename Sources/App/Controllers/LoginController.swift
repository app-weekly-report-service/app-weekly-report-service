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
        let loginGroup = routes.grouped("login")
        /// 注册 POST /login 路由进行登录
        loginGroup.post(use: login)
    }
    
    func login(_ req: Request) async throws -> String {
        /// 验证 Content 的参数是否满足条件
        try UserRequestContent.validate(content: req)
        let content = try req.content.decode(UserRequestContent.self)
        guard let user = try await User.query(on: req.db).filter(\.$username == content.username).first() else {
            throw LoginAbort().userNotExit.abort
        }
        guard try await req.password.async.verify(content.password, created: user.password) else {
            throw LoginAbort().passwordError.abort
        }
        /// 用户存在 代表登陆成功
        return [UInt8].random(count: 32).base64String()
    }
}

/// 解析登陆接口参数信息
struct UserRequestContent: Content {
    /// 用户名
    let username: String
    /// 密码
    let password: String
}

extension UserRequestContent: Validatable {
    static func validations(_ validations: inout Validations) {
        /// 要求 username 必须是字符串类型 不能为空 字段必须存在
        validations.add("username", as: String.self, is: !.empty, required: true)
        /// 要求 password 必须是字符串类型 不能为空 字段必须存在
        validations.add("password", as: String.self, is: !.empty, required: true)
    }
}
