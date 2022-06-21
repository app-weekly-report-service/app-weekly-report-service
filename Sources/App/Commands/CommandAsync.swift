//
//  CommandAsync.swift
//  
//
//  Created by 张行 on 2022/6/21.
//

import Foundation
import Vapor

protocol CommandAsync: Command {
    func runAsync(using context: CommandContext, signature: Signature) async throws
}

extension CommandAsync {
    func run(using context: CommandContext, signature: Signature) throws {
        let promise = context.application.eventLoopGroup.next().makePromise(of: Void.self)
        promise.completeWithTask {
            try await runAsync(using: context, signature: signature)
        }
        try promise.futureResult.wait()
    }
}
