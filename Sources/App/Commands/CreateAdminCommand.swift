//
//  CreateAdminCommand.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Vapor
import FluentKit

struct CreateAdminCommand: Command {
    let help: String = "通过命令行创建管理员账户"
    
    typealias Signature = SignatureContent
    struct SignatureContent: CommandSignature {
        @Argument(name: "username", help: "用户名")
        var username: String
        
        @Argument(name: "password", help: "密码")
        var password: String
    }
    
    func run(using context: CommandContext, signature: SignatureContent) throws {
        /// 异步变成同步
        let promise = context.application.eventLoopGroup.next().makePromise(of:Void.self)
        promise.completeWithTask {
            try await runAsync(using: context, signature: signature)
        }
        try promise.futureResult.wait()
    }
    
    private func runAsync(using context: CommandContext,
                          signature: SignatureContent) async throws {
        let app = context.application
        let db = app.db
        /// 查询创建的管理员账户是否已经存在
        guard try await User.query(on: db).filter(\.$username == signature.username).count() == 0 else {
            throw UserAbort().exit(signature.username).abort
        }
        let password = try await app.password.async.hash(signature.password)
        let user = User(username: signature.username,
                        password: password,
                        isAdmin: true)
        /// 保存用户到数据库
        try await user.save(on: db)
        context.console.output("创建管理员 \(signature.username) 成功!".consoleText(color: .green))
    }
}

