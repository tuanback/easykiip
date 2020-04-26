//
//  RemoteUserSession.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct RemoteUserSession: Codable {

  // MARK: - Properties
  let token: AuthToken

  // MARK: - Methods
  public init(token: AuthToken) {
    self.token = token
  }
}

extension RemoteUserSession: Equatable {
  
  public static func ==(lhs: RemoteUserSession, rhs: RemoteUserSession) -> Bool {
    return lhs.token == rhs.token
  }
}
