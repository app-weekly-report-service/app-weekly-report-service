//
//  LoginController.swift
//  
//
//  Created by 张行 on 2022/6/15.
//

import Foundation
import Vapor

/// 管理用户登录
struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let loginGroup = routes.grouped("login")
        /// 注册 POST /login 路由进行登录
        loginGroup.post(use: login)
    }
    
    func login(_ req: Request) async throws -> String {
        return [UInt8].random(count: 32).base64String()
    }
}
