//
//  UserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import GoogleSignIn

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
  
  /// Log in with firebase
  /// - Parameters:
  ///   - credential: credential from provider
  ///   - provider: provider
  func signIn(with credential: AuthCredential, provider: Provider) -> Observable<AuthState>
  /// If user uses second factor login, show a pop up to let user select factor to signed in
  /// - Parameter name: if they select phone
  func handleUserSelectFactorToLogIn(name: String)
  /// When user enter verification code to their phone
  /// - Parameter code: verification code
  func handleUserSelectedVerificationCode(_ code: String)
}
