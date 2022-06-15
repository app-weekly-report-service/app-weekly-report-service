//
//  LoginTests.swift
//  
//
//  Created by king on 2022/6/15.
//

@testable import App
import XCTVapor

final class LoginTests: XCTestCase {
    /// 测试登陆
    func testLogin() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        /// 创建测试账号
        let testUser = User(username: "test", password: "test")
        try await testUser.save(on: app.db)
        
        /// 登录成功
        let resSuccess = try await app.sendRequest(.POST, "/login", beforeRequest: { req async throws in
            try req.content.encode([
                "username": "test",
                "password": "test"
            ])
        })
        /// 登录失败
        let resFailure = try await app.sendRequest(.POST, "/login", beforeRequest: { req async throws in
            try req.content.encode([
                "username": "test",
                "password": "test123"
            ])
        })
        
        /// 删除测试账号
        try await testUser.delete(on: app.db)
        
        /// 验证登陆结果
        XCTAssertEqual(resSuccess.status.code, 200)
        XCTAssertEqual(resFailure.status.code, 500)
        
    }
}
