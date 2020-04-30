//
//  AuthRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

public protocol AuthRemoteAPI {
  func signIn(email: String, password: String) -> Observable<UserSession>
  func signIn(provider: Provider, token: String, clientId: String) -> Observable<UserSession>
  func signUp(account: NewAccount) -> Observable<UserSession>
}
