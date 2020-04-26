//
//  AuthRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol AuthRemoteAPI {
  
  func signIn(username: String, password: String) -> UserSession
  func signUp(account: NewAccount) -> UserSession
}
