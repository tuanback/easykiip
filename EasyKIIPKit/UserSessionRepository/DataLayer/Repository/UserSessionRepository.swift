//
//  UserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol UserSessionRepository {
  
  func readUserSession() -> UserSession?
  func signUp(newAccount: NewAccount) -> UserSession
  func signIn(email: String, password: String) -> UserSession
  func signOut(userSession: UserSession)
}
