//
//  UserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

public enum Provider {
  case google
  case facebook
  case apple
}

public enum AuthState {
  case authenticating
  case waitingForDisplayName(displayName: String)
  case waitingForVerificationCode(displayName: String)
  case success(userSession: UserSession)
}

public protocol UserSessionRepository {
  func readUserSession() -> UserSession?
  func signUp(newAccount: NewAccount) -> Observable<UserSession>
  func signIn(email: String, password: String) -> Observable<UserSession>
  func signOut()
}
