//
//  Articles.swift
//  
//
//  Created by 张行 on 2022/6/22.
//

import Foundation
import FluentKit

/// 技术文章
final class Articles: Model {
    static var schema: String = "articles"
    
    typealias IDValue = UUID
    
    @ID(key: .id)
    var id: UUID?
    
    /// 发布用户唯一ID
    @Field(key: "user_id")
    var userId: UUID
    
    /// 技术文章标题
    @Field(key: "title")
    var title: String
    
    /// 技术文章内容
    @Field(key: "content")
    var content: String
    
    /// 文章创建时间
    @Timestamp(key: "create_time", on: .create)
    var createTime: Date?
    
    /// 文章更新时间
    @Timestamp(key: "update_time", on: .update)
    var updateTime: Date?
    
    init() {}
    
    init(from userId: UUID, title: String, content: String) {
        self.userId = userId
        self.title = title
        self.content = content
    }
}
