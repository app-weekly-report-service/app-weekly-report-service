//
//  UserController.swift
//  
//
//  Created by 张行 on 2022/6/21.
//

import Foundation
import Vapor
import FluentKit

/// 管理用户
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        /// 添加 管理员中间件
        routes.admin.grouped("admin").group("user") { user in
            /// 新增用户
            user.post(use: create)
            
            user.group(":id") { user in
                /// 重置密码
                user.put(use: resetPassword)
                /// 删除用户
                user.delete(use: delete)
            }
        }
        
        /// /user 管理
        routes.token.group("user") { user in
            /// 更新用户信息
            user.put(use: update)
            user.get(use: getUserInfo)
        }
    }
    
    /// 新增用户
    func create(_ req: Request) async throws -> AppResponse<Bool> {
        /// 验证参数信息
        try CreateUserContent.validate(content: req)
        /// 获取请求参数
        let content = try req.content.decode(CreateUserContent.self)
        /// 加密密码
        let password = try await req.password.async.hash(content.password)
        guard try await User.query(on: req.db).filter(\User.$username == content.username).count() == 0 else {
            /// 新增的用户已经存在
            throw UserAbort().exit(content.username).abort
        }
        /// 创建用户
        let user = User(username: content.username, password: password)
        try await user.save(on: req.db)
        return .init(success: true)
    }
    
    /// 重新设置密码
    func resetPassword(_ req: Request) async throws -> AppResponse<Bool> {
        try ResetPasswordContent.validate(content: req)
        /// 获取请求路径上面的用户ID
        guard let userId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.notFound)
        }
        let content = try req.content.decode(ResetPasswordContent.self)
        /// 查询对应的用户
        guard let user = try await User.find(userId, on: req.db) else {
            throw UserAbort().notExit(userId).abort
        }
        /// 对于新密码加密
        let password = try await req.password.async.hash(content.password)
        /// 保存新的密码到用户
        user.password = password
        try await user.save(on: req.db)
        return .init(success: true)
    }
    
    /// 删除用户
    func delete(_ req: Request) async throws -> AppResponse<Bool> {
        guard let userId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.notFound)
        }
        guard let user = try await User.find(userId, on: req.db) else {
            throw UserAbort().notExit(userId).abort
        }
        /// 删除用户
        try await user.delete(on: req.db)
        return .init(success: true)
    }
    
    /// 更新用户
    func update(_ req: Request) async throws -> AppResponse<Bool> {
        /// 获取当前授权的用户
        let user = try req.auth.require(User.self)
        try UpdateUserContent.validate(content: req)
        let content = try req.content.decode(UpdateUserContent.self)
        /// 更新用户信息
        user.nikeName = content.nikeName
        try await user.save(on: req.db)
        return .init(success: true)
    }
    
    func getUserInfo(_ req: Request) async throws -> AppResponse<UserInfo> {
        let user = try req.auth.require(User.self)
        return .init(success: .init(nikeName: user.nikeName, isAdmin: user.isAdmin))
    }
}

extension UserController {
    struct CreateUserContent: UserContent {
        let username: String
        let password: String
    }
}

extension UserController {
    struct ResetPasswordContent: Content, Validatable {
        /// 新密码
        let password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("password", as: String.self, is: !.empty, required: true)
        }
    }
}

extension UserController {
    struct UpdateUserContent: Content, Validatable {
        /// 用户名
        let nikeName: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("nikeName", as: String.self, is: !.empty, required: true)
        }
    }
}

extension UserController {
    struct UserInfo: Content {
        let nikeName: String
        let isAdmin: Bool
    }
}
