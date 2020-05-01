//
//  UserSessionDataStore.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public typealias AuthToken = String

public protocol UserSessionDataStore {
  func readUserSession() -> UserSession?
  func save(userSession: UserSession)
  func delete()
}
