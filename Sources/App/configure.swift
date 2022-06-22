import Fluent
import FluentPostgresDriver
import Vapor
import QueuesFluentDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    /// 注意需要配置在 `app.databases.use`之前 useSoftDeletes 设置非软删除 直接从数据库将数据删除
    app.queues.use(.fluent(useSoftDeletes: false))
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "app_weekly_report_service"
    ), as: .psql)
    
    /// 创建 User 表
    app.migrations.add(CreateUserMigration())
    /// 创建 Token 表
    app.migrations.add(CreateTokenMigration())
    /// 添加 Flent 队列迁移 支持队列
    app.migrations.add(JobModelMigrate())
    /// 新增 `is_admin`字段
    app.migrations.add(UpdateUserMigration())
    /// 等待迁移完毕
    try app.autoMigrate().wait()
    
    /// 设置密码使用`bcrypt`进行加密
    app.passwords.use(.bcrypt)

    // register routes
    try routes(app)
    
    if (app.environment != .testing) {
        /// 在测试环境 不允许启动队列任务
        try app.queues.startInProcessJobs()
    }
    

    app.commands.use(AdminGroupCommand(), as: "admin")
    
    /// 注册系统拦取异常封装为 AppResponse 返回
    app.middleware.use(AppResponseMiddle())
}
