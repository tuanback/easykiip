//
//  NewAccount.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct NewAccount: Codable {

  // MARK: - Properties
  public let email: String
  public let password: String

  // MARK: - Methods
  public init(email: String,
              password: String) {
    self.email = email
    self.password = password
  }
}
