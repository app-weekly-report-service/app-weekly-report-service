import Fluent
import Vapor

func routes(_ app: Application) throws {
    /// 注册登陆接口
    try app.register(collection: LoginController())
}
