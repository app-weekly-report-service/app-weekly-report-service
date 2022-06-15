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
        let content = try req.content.decode(UserRequestContent.self)
        guard let user = try await User.query(on: req.db).filter(\.$username == content.username).filter(\.$password == content.password).first() else {
            throw Abort(.custom(code: 500, reasonPhrase: "用户名或者密码错误!"))
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
