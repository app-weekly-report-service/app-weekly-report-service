//
//  AppResponseMiddle.swift
//  
//
//  Created by 张行 on 2022/6/22.
//

import Foundation
import Vapor

/// 拦截所有的请求异常处理为 AppResponse 数据结构 中间件
struct AppResponseMiddle: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            /// 执行后面路由 看是否有异常
            return try await next.respond(to: request)
        } catch (let e) {
            /// 接受到异常 如果异常不是 AbortError 则代表服务器语法出现了问题
            let abort = e as? AbortError ?? Abort(.badRequest)
            /// 将捕获的异常封装成 AppResponse
            let appResponse = AppResponse<String>(failure: abort.status.code, message: abort.reason)
            /// 将 AppResponse 错误封装成 Response 此处的异常无法再捕获 理论上也不会有异常
            return try await appResponse.encodeResponse(for: request)
        }
    }
}

