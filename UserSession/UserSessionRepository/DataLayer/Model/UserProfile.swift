//
//  UserProfile.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct UserProfile: Equatable, Codable {

  // MARK: - Properties
  public let id: String
  public let name: String
  public let email: String
  public let avatar: String?

  // MARK: - Methods
  public init(id: String, name: String, email: String, avatar: String?) {
    self.id = id
    self.name = name
    self.email = email
    self.avatar = avatar
  }
}
