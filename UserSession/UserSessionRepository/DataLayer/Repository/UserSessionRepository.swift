//
//  UserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

public protocol UserSessionRepository {
  func readUserSession() -> UserSession?
  func signUp(newAccount: NewAccount) -> Observable<UserSession>
  func signIn(email: String, password: String) -> Observable<UserSession>
  func signOut(userSession: UserSession)
}
