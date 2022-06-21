import Fluent
import Vapor

func routes(_ app: Application) throws {
    /// 注册登陆接口
    try app.register(collection: LoginController())
    /// 注册密码路由
    try app.register(collection: PasswordController())
    /// 用户管理
    try app.register(collection: UserController())
}
