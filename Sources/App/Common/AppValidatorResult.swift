//
//  AppValidatorResult.swift
//  
//
//  Created by 张行 on 2022/6/17.
//

import Foundation
import Vapor

struct AppValidatorResult: ValidatorResult {
    let isFailure: Bool
    let successDescription: String?
    let failureDescription: String?
    
    init(success successDescription: String?) {
        self.isFailure = false
        self.successDescription = successDescription
        self.failureDescription = nil
    }
    
    init(failure failureDescription: String) {
        self.isFailure = true
        self.successDescription = nil
        self.failureDescription = failureDescription
    }
}
