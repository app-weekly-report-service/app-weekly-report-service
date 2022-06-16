import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "app_weekly_report_service"
    ), as: .psql)
    
    /// 创建 User 表
    app.migrations.add(CreateUserMigration())
    /// 等待迁移完毕
    try app.autoMigrate().wait()
    
    /// 设置密码使用`bcrypt`进行加密
    app.passwords.use(.bcrypt)

    // register routes
    try routes(app)
}
