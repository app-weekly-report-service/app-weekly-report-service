//
//  MakeAdminCommand.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Vapor
import FluentKit

struct MakeAdminCommand: CommandAsync {
    let help: String = "将指定用户修改为管理员"
    typealias Signature = MakeAdminSignature
    
    func runAsync(using context: CommandContext, signature: MakeAdminSignature) async throws {
        let db = context.application.db
        let username = signature.username
        /// 查询对应 username 的用户
        guard let user = try await User.query(on: db).filter(\.$username == username).first() else {
            throw UserAbort().noExitUserName(username).abort
        }
        /// 修改为管理员账户
        user.isAdmin = true
        try await user.save(on: db)
        context.console.output(username.consoleText(color: .red) + "修改为管理员成功!".consoleText(color: .green))
    }
}

struct MakeAdminSignature: CommandSignature {
    @Argument(name: "username", help: "用户名")
    var username: String
}
