//
//  RouteBuilder+AppResponse.swift
//  
//
//  Created by 张行 on 2022/6/17.
//

import Foundation
import Vapor

typealias AppResponseClosure<T: Content> = (Request) async throws -> AppResponse<T>

extension RoutesBuilder {
    @discardableResult
    func onRoute<T: Content>(_ method: HTTPMethod,
                             _ path: PathComponent...,
                             body: HTTPBodyStreamStrategy = .collect,
                             use closure: @escaping AppResponseClosure<T>) -> Route  {
        return self.on(method, path, body: body, use: { req async throws in
            do {
                return try await closure(req)
            } catch(let e) {
                let abort = e as? AbortError ?? Abort(.internalServerError)
                return AppResponse<T>(failure: abort.status.code, message: abort.reason)
            }
        })
    }
}
