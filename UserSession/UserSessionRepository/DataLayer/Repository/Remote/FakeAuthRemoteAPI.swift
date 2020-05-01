//
//  FakeAuthRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

public struct FakeAuthRemoteAPI: AuthRemoteAPI {

  // MARK: - Methods
  public init() {}

  public func signIn(email: String, password: String) -> Observable<UserSession> {
    guard email == "tuan@gmail.com" && password == "123456" else {
      return Observable.error(AuthError.loginFailed)
    }
    
    let userSession = createFakeUserSession()
    return Observable.just(userSession)
  }

  public func signUp(account: NewAccount) -> Observable<UserSession> {
    let userSession = createFakeUserSession()
    return Observable.just(userSession)
  }
  
  private func createFakeUserSession() -> UserSession {
    let profile = UserProfile(id: "1", name: "Tuan Do",
                              email: "tuan@gmail.com",
                              avatar: "http://www.koober.com/avatar/johnnya")
    let remoteUserSession = RemoteUserSession(token: "64652626")
    let userSession = UserSession(profile: profile, remoteSession: remoteUserSession)
    return userSession
  }
}
