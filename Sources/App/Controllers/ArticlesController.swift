//
//  ArticlesController.swift
//  
//
//  Created by 张行 on 2022/6/22.
//

import Foundation
import Vapor

/// 管理技术文章
struct ArticlesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.token.group("article") { article in
            /// 新增技术文章
            article.post(use: add)
            article.group(":id") { article in
                /// 删除指定的技术文章
                article.delete(use: delete)
                article.put(use: edit)
            }
        }
        routes.token.group("articles") { articles in
            /// 批量删除
            articles.delete(use: deletes)
        }
    }
    
    /// 新增文章
    func add(_ req: Request) async throws -> AppResponse<Bool> {
        /// 获取当前用户
        let user = try req.auth.require(User.self)
        /// 验证请求参数
        try AddArticlesContent.validate(content: req)
        /// 获取请求参数
        let content = try req.content.decode(AddArticlesContent.self)
        /// 新建 Articles
        let articles = Articles(from: try user.requireID(), title: content.title, content: content.content)
        /// 保存到数据库
        try await articles.save(on: req.db)
        return .init(success: true)
    }
    
    /// 删除对应的技术文章
    func delete(_ req: Request) async throws -> AppResponse<Bool> {
        /// 获取操作的技术文章唯一 ID
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw ArticleAbort().notId.abort
        }
        /// 根据 ID 查询技术文章
        guard let article = try await Articles.find(id, on: req.db) else {
            throw ArticleAbort().notExit(id).abort
        }
        /// 删除技术文章
        try await article.delete(on: req.db)
        return .init(success: true)
    }
    
    /// 编辑技术文章
    func edit(_ req: Request) async throws -> AppResponse<Bool> {
        /// 验证请求内容
        try ChangeArticlesContent.validate(content: req)
        /// 获取请求内容
        let content = try req.content.decode(ChangeArticlesContent.self)
        /// 获取文章对应的ID
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw ArticleAbort().notId.abort
        }
        /// 根据 ID 查询对应文章
        guard let article = try await Articles.find(id, on: req.db) else {
            throw ArticleAbort().notExit(id).abort
        }
        if let title = content.title {
            /// 修改标题
            article.title = title
        }
        if let content = content.content {
            /// 修改内容
            article.content = content
        }
        /// 保存到数据库
        try await article.save(on: req.db)
        return .init(success: true)
    }
    
    /// 批量删除文章
    func deletes(_ req: Request) async throws -> AppResponse<Bool> {
        try DeleteArtilesContent.validate(content: req)
        let content = try req.content.decode(DeleteArtilesContent.self)
        try await withThrowingTaskGroup(of: Void.self, body: { taskGroup in
            content.ids.forEach { id in
                taskGroup.addTask {
                    /// 查询文章是否存在
                    guard let article = try await Articles.find(id, on: req.db) else {
                        throw ArticleAbort().notExit(id).abort
                    }
                    try await article.delete(on: req.db)
                }
            }
            try await taskGroup.waitForAll()
        })
        return .init(success: true)
    }
}


extension ArticlesController {
    struct AddArticlesContent: Content, ArticlesContentValidatable {
        let title: String
        let content: String
        
        static var titleRequired: Bool = true
        static var contentRequired: Bool = true
    }
}

extension ArticlesController {
    struct ChangeArticlesContent: Content, ArticlesContentValidatable {
        let title: String?
        let content: String?
        
        static var titleRequired: Bool = false
        static var contentRequired: Bool = false
    }
}


protocol ArticlesContentValidatable: Validatable {
    static var titleRequired: Bool { get }
    static var contentRequired: Bool { get }
}

extension ArticlesContentValidatable {
    static func validations(_ validations: inout Validations) {
        /// title 最少 10个字符
        validations.add("title",
                        as: String.self,
                        is: .count(10...),
                        required: titleRequired)
        /// 内容最少20个字符
        validations.add("content",
                        as: String.self,
                        is: .count(20...),
                        required: contentRequired)
    }
}


extension ArticlesController {
    struct DeleteArtilesContent: Content, Validatable {
        /// 需要删除的 ID 数组
        let ids: [UUID]
        
        static func validations(_ validations: inout Validations) {
            validations.add("ids", as: [UUID].self, is: !.empty, required: true)
        }
    }
}
