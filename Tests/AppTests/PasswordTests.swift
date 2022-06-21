//
//  PasswordTests.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
@testable import App
import XCTVapor

final class PasswordTests: XCTestCase {
    
    /// 测试修改密码
    func testResetPassword() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let testUserId = "999999"
        if let user = try await User.query(on: app.db).first() {
            try await user.delete(on: app.db)
        }
        let password = try await app.password.async.hash("123456")
        let user = User(username: testUserId, password: password)
        try await user.save(on: app.db)
        
        let loginRes = try await app.sendRequest(.POST, "/login", beforeRequest: { req async throws in
            try req.content.encode([
                "username": testUserId,
                "password": "123456"
            ])
        })
        guard let tokenString = try loginRes.content.decode(AppResponse<String>.self).data else {
            XCTFail()
            return
        }
        
        let resetPassword = try await app.sendRequest(.PUT, "/password", beforeRequest: { req async throws in
            req.headers.bearerAuthorization = BearerAuthorization(token: tokenString)
            try req.content.encode([
                "oldPassword": "123456",
                "newPassword": "654321"
            ])
        })
        try await user.delete(on: app.db)

        XCTAssertEqual(try resetPassword.content.decode(AppResponse<Bool>.self).code, 200)
    }
}
