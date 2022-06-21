//
//  AppError.swift
//  
//
//  Created by 张行 on 2022/6/16.
//

import Foundation
import Vapor

/// 模块错误码协议
protocol ModuleError {
    /// 错误码
    var code: UInt { get }
}

/// AppError 错误码
struct AppErrorCode {
    /// 对应模型
    let model: ModuleError
    /// 错误码
    let code: UInt
    
    var errorCode: UInt {
        model.code + code
    }
}

/// 模块具体错误协议
struct AppError {
    /// 错误吗
    let code: AppErrorCode
    /// 错误信息
    let message: String
    
    /// 生成 Abort 对象
    var abort: Abort {
        .init(.custom(code: code.errorCode, reasonPhrase: message))
    }
}

/// 登录模块的错误吗
struct LoginAbort: ModuleError {
    let code: UInt = 100000
    
    /// 用户不存在!
    var userNotExit: AppError {
        .init(code: .init(model: self, code: 1), message: "用户不存在!")
    }
    
    /// 登录密码错误!
    var passwordError: AppError {
        .init(code: .init(model: self, code: 2), message: "登录密码错误!")
    }
}


struct TokenAbort: ModuleError {
    let code: UInt = 200000
    
    var invalid: AppError {
        .init(code: .init(model: self, code: 1), message: "Token 无效!")
    }
    
    var expired: AppError {
        .init(code: .init(model: self, code: 2), message: "Token 已过期!")
    }
}


struct UserAbort: ModuleError {
    let code: UInt = 300000
    
    func notExit(_ userId: UUID) -> AppError {
        .init(code: .init(model: self, code: 1), message: "用户 \(userId) 不存在!")
    }
    
    func exit(_ username: String) -> AppError {
        .init(code: .init(model: self, code: 2), message: "\(username) 已经存在!")
    }
    
    func noExitUserName(_ username: String) -> AppError {
        .init(code: .init(model: self, code: 3), message: "用户名 \(username) 不存在！")
    }
    
    var notAdmin: AppError {
        .init(code: .init(model: self, code: 4), message: "当前用户不是管理员!")
    }
}

struct PasswordAbort: ModuleError {
    let code: UInt = 400000
    
    var notSame: AppError {
        .init(code: .init(model: self, code: 1), message: "旧密码和新密码不能相同!")
    }
    
    var oldPasswordIncorrect: AppError {
        .init(code: .init(model: self, code: 2), message: "之前密码不正确!")
    }
}
