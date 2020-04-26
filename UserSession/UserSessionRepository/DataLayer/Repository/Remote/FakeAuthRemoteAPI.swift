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
    guard email == "tuan@gmail.com" && password == "password" else {
      return Observable.create { (observer) -> Disposable in
        observer.onError(NetworkError.loginFailed)
        return Disposables.create()
      }
    }
    return Observable.create { (observer) -> Disposable in
      sleep(2)
      let profile = UserProfile(name: "Johnny Appleseed",
                                email: "johnny@gmail.com",
                                avatar: makeURL())
      let remoteUserSession = RemoteUserSession(token: "64652626")
      let userSession = UserSession(profile: profile, remoteSession: remoteUserSession)
      
      observer.onNext(userSession)
      observer.onCompleted()
      return Disposables.create()
    }
  }

  public func signUp(account: NewAccount) -> Observable<UserSession> {
    let profile = UserProfile(name: account.name,
                              email: account.email,
                              avatar: makeURL())
    let remoteUserSession = RemoteUserSession(token: "984270985")
    let userSession = UserSession(profile: profile, remoteSession: remoteUserSession)
    return Observable.just(userSession)
  }
}
