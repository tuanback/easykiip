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
  public let name: String
  public let email: String
  public let password: String

  // MARK: - Methods
  public init(name: String,
              email: String,
              password: String) {
    self.name = name
    self.email = email
    self.password = password
  }
}
