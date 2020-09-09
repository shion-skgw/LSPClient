//
//  ParameterType.swift
//  LSPClient
//
//  Created by Shion on 2020/06/10.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

protocol ParamsType: Codable {}

protocol RequestParamsType: ParamsType {}

protocol NotificationParamsType: ParamsType {}

protocol ResultType: Codable {}

extension Array: ResultType where Element: ResultType {}
extension Optional: ResultType where Wrapped: ResultType {}
