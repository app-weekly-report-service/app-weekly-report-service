//
//  PasswordController.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Vapor

/// 密码管理
struct PasswordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let password = routes.response.token.grouped("password")
        /// 设置 PUT 方式来修改密码
        password.put(use: reset)
    }
    
    /// 重设密码
    func reset(_ req: Request) async throws -> AppResponse<Bool> {
        /// 验证重设密码的请求参数是否符合要求
        try ResetPasswordContent.validate(content: req)
        /// 获取重设密码的请求参数
        let content = try req.content.decode(ResetPasswordContent.self)
        /// 旧密码和新密码不能相同
        guard content.oldPassword != content.newPassword else {
            throw PasswordAbort().notSame.abort
        }
        /// 获取当前登录的用户
        let user = try req.auth.require(User.self)
        /// 验证旧密码是否正确
        guard try await req.password.async.verify(content.oldPassword,
                                                  created: user.password) else {
            throw PasswordAbort().oldPasswordIncorrect.abort
        }
        /// 验证密码成功 将密码修改为新密码
        user.password = try await req.password.async.hash(content.newPassword)
        /// 保存到数据库
        try await user.save(on: req.db)
        /// 返回结果
        return .init(success: true)
    }
}

/// 重设密码的内容
struct ResetPasswordContent: Content, Validatable {
    /// 旧密码
    let oldPassword: String
    /// 新密码
    let newPassword: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("oldPassword",
                        as: String.self,
                        is: !.empty,
                        required: true)
        validations.add("newPassword",
                        as: String.self,
                        is: !.empty,
                        required: true)
    }
}

