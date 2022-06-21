//
//  DeleteTokenJob.swift
//  
//
//  Created by 张行 on 2022/6/20.
//

import Foundation
import Queues
import Vapor

/// 删除 Token 队列
struct DeleteTokenJob: AsyncJob {
    typealias Payload = PayloadContent
    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        /// 获取 Token 的唯一ID
        let tokenId = payload.tokenId
        /// 获取数据库对象
        let db = context.application.db
        /// 查询 Token 是否存在
        guard let token = try await Token.find(tokenId, on: db) else {
            /// 代表 Token ID 错误或者 已经被其他的删除 则完成任务
            return
        }
        /// 删除 Token
        try await token.delete(on: db)
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: Payload) async throws {
        /// 获取 Logger
        let logger = context.logger
        /// 打印错误
        logger.error(.init(stringLiteral: error.localizedDescription))
        /// 获取 Queue
        let queue = context.queue
        /// 删除 Token 错误， 设置五分钟之后重试
        try await queue.dispatch(DeleteTokenJob.self,
                                        payload,
                                        maxRetryCount: 3,
                                        delayUntil: Date().addingTimeInterval(5 * 60))
    }
}

extension DeleteTokenJob {
    struct PayloadContent: Content {
        /// Token 的数据库唯一ID
        let tokenId: UUID
    }
}
