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
        loginGroup.post { req async throws in
            do {
                return try await login(req)
            } catch(let e) {
                let abort = e as? AbortError ?? Abort(.internalServerError)
                return AppResponse<String>(failure: abort.status.code, message: abort.reason)
            }
        }
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
        /// 用户存在 代表登陆成功
        return .init(success: [UInt8].random(count: 32).base64String())
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
        validations.add("username", as: String.self, is: .usernameValidator, required: true)
        /// 要求 password 必须是字符串类型 不能为空 字段必须存在
        validations.add("password", as: String.self, is: !.empty, required: true)
    }
}

extension Validator {
    /// 新建一个 Validator<T> 对象 用于可以支持自定义验证
    static var usernameValidator: Validator<String> {
        .init { data in
            guard data.count == 6 else {
                return AppValidatorResult(failure: "必须是 6 位数，不足在前面补 0!")
            }
            guard let _ = Int(data) else {
                return AppValidatorResult(failure: "必须 [0-9] 数组组成!")
            }
            return AppValidatorResult(success: nil)
        }
    }
}

