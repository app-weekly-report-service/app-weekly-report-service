//
//  AppResponse.swift
//  
//
//  Created by 张行 on 2022/6/17.
//

import Foundation
import Vapor

/// 接口的统一返回模型
struct AppResponse<T: Content>: Content {
    /// 状态吗
    let code: UInt
    /// 返回信息
    let message: String
    /// 是否成功
    let isSuccess: Bool
    /// 成功返回数据
    let data: T?
    
    /// 成功
    /// - Parameter data: 成功数据
    init(success data: T?) {
        self.code = 200
        self.message = "success"
        self.isSuccess = true
        self.data = data
    }
    
    /// 失败
    /// - Parameters:
    ///   - code: 失败状态吗
    ///   - message: 失败的信息
    init(failure code: UInt, message: String) {
        self.code = code
        self.message = message
        self.isSuccess = false
        self.data = nil
    }
}
