//
//  FirebaseUserSessionDataStore.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

public class FirebaseUserSessionDataStore: UserSessionDataStore {
  
  public init() {
    
  }
  
  public func readUserSession() -> UserSession? {
    guard let currentUser = Auth.auth().currentUser else {
      return nil
    }
    return makeUserSession(from: currentUser)
  }
  
  private func makeUserSession(from user: User) -> UserSession {
    let profile = UserProfile(id: user.uid, name: user.displayName ?? "", email: user.email ?? "", avatar: user.email)
    let remoteSession = RemoteUserSession(token: user.refreshToken ?? "")
    let userSession = UserSession(profile: profile, remoteSession: remoteSession)
    return userSession
  }
  
  public func save(userSession: UserSession) {
    
  }
  
  public func delete() {
    
  }
}
