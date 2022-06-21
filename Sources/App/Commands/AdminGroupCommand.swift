//
//  AdminGroupCommand.swift
//  
//
//  Created by 张行 on 2022/6/21.
//

import Foundation
import Vapor

/// 管理员命令分组
struct AdminGroupCommand: CommandGroup {
    let help: String = "可以管理管理员用户"
    
    let commands: [String : AnyCommand] = [
        "create": CreateAdminCommand(),
        "make": MakeAdminCommand()
    ]
    
    let defaultCommand: AnyCommand? = nil
}
