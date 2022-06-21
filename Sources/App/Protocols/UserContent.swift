//
//  UserContent.swift
//  
//
//  Created by 张行 on 2022/6/21.
//

import Foundation
import Vapor

protocol UserContent: Content, Validatable {
    /// 用户名
    var username: String { get }
    /// 密码
    var password: String { get }
}

extension UserContent {
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

