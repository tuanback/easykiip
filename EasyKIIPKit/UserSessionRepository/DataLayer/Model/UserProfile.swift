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
  public let name: String
  public let email: String
  public let mobileNumber: String
  public let avatar: URL

  // MARK: - Methods
  public init(name: String, email: String, mobileNumber: String, avatar: URL) {
    self.name = name
    self.email = email
    self.mobileNumber = mobileNumber
    self.avatar = avatar
  }
}
