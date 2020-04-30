//
//  FakeAuthRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

public enum NetworkError: Error {
  case loginFailed
}

public struct FakeAuthRemoteAPI: AuthRemoteAPI {

  // MARK: - Methods
  public init() {}

  public func signIn(email: String, password: String) -> Observable<UserSession> {
    guard email == "tuan@gmail.com" && password == "123456" else {
      return Observable.error(NetworkError.loginFailed)
    }
    
    let userSession = createFakeUserSession()
    return Observable.just(userSession)
  }
  
  public func signIn(provider: Provider, token: String, clientId: String) -> Observable<UserSession> {
    let userSession = createFakeUserSession()
    return Observable.just(userSession)
  }

  public func signUp(account: NewAccount) -> Observable<UserSession> {
    let userSession = createFakeUserSession()
    return Observable.just(userSession)
  }
  
  private func createFakeUserSession() -> UserSession {
    let profile = UserProfile(name: "Tuan Do",
                              email: "tuan@gmail.com",
                              avatar: makeURL())
    let remoteUserSession = RemoteUserSession(token: "64652626")
    let userSession = UserSession(profile: profile, remoteSession: remoteUserSession)
    return userSession
  }
}
