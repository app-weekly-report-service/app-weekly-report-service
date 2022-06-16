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
        /// 对密码进行加密
        let password = try await app.password.async.hash("test")
        /// 创建测试账号
        let testUser = User(username: "test", password: password)
        try await testUser.save(on: app.db)
        
        /// 登录成功
        let resSuccess = try await login("test", "test", app)
        /// 登录失败
        let resFailure = try await login("test", "test123", app)
        
        /// 删除测试账号
        try await testUser.delete(on: app.db)
        
        /// 验证登陆结果
        XCTAssertEqual(resSuccess.status.code, 200)
        XCTAssertEqual(resFailure.status.code, LoginAbort().passwordError.code.errorCode)
        
    }
    
    func testLoginContentValidatable() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        /// 验证用户名 不是字符串类型
        let res1 = try await login(123, "test123", app)
        XCTAssertEqual(try res1.content.decode(ErrorReason.self).reason, "username is not a(n) String")
        
        let username: String? = nil
        /// 验证用户名 不存在
        let res2 = try await login(username, "test123", app)
        XCTAssertEqual(try res2.content.decode(ErrorReason.self).reason, "username is required")
        
        /// 验证用户名 不能为空字符串
        let res3 = try await login("", "test123", app)
        XCTAssertEqual(try res3.content.decode(ErrorReason.self).reason, "username is empty")
    }
    
    /// 登录请求信息
    struct LoginContent<T: Content, S: Content>: Content {
        /// 用户名
        let username: T?
        /// 密码
        let password: S?
    }
    
    /// 登录获取返回信息
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - app: Application 服务
    /// - Returns: XCTHTTPResponse 返回值
    func login<T: Content, S: Content>(_ username: T?,
                                       _ password: S?,
                                       _ app: Application) async throws -> XCTHTTPResponse {
        try await app.sendRequest(.POST, "/login", beforeRequest: { req async throws in
            try req.content.encode(LoginContent(username: username, password: password))
        })
    }
    
    struct ErrorReason: Content {
        let error: Bool
        let reason: String
    }
}
