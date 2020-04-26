//
//  UserSession.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class UserSession: Codable {

  // MARK: - Properties
  public let profile: UserProfile
  public let remoteSession: RemoteUserSession

  // MARK: - Methods
  public init(profile: UserProfile, remoteSession: RemoteUserSession) {
    self.profile = profile
    self.remoteSession = remoteSession
  }
}

extension UserSession: Equatable {
  
  public static func ==(lhs: UserSession, rhs: UserSession) -> Bool {
    return lhs.profile == rhs.profile &&
           lhs.remoteSession == rhs.remoteSession
  }
}
