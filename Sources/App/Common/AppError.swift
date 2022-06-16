//
//  AppError.swift
//  
//
//  Created by 张行 on 2022/6/16.
//

import Foundation
import Vapor

/// 模块错误码协议
protocol ModelError {
    /// 错误码
    var code: UInt { get }
}

/// AppError 错误码
struct AppErrorCode {
    /// 对应模型
    let model: ModelError
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
struct LoginAbort: ModelError {
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


