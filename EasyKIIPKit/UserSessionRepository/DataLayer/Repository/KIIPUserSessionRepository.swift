//
//  KIIPUserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class KIIPUserSessionRepository: UserSessionRepository {

  // MARK: - Properties
  let dataStore: UserSessionDataStore
  let remoteAPI: AuthRemoteAPI

  // MARK: - Methods
  public init(dataStore: UserSessionDataStore, remoteAPI: AuthRemoteAPI) {
    self.dataStore = dataStore
    self.remoteAPI = remoteAPI
  }

  public func readUserSession() -> UserSession? {
    return dataStore.readUserSession()
  }

  public func signUp(newAccount: NewAccount) -> UserSession {
    let userSession = remoteAPI.signUp(account: newAccount)
    dataStore.save(userSession: userSession)
    return userSession
  }

  public func signIn(email: String, password: String) -> UserSession {
    let userSession = remoteAPI.signIn(username: email, password: password)
    dataStore.save(userSession: userSession)
    return userSession
  }

  public func signOut(userSession: UserSession) {
    return dataStore.delete(userSession: userSession)
  }
}
