//
//  FirebaseUserSessionDataStore.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import Firebase
import GoogleSignIn
import FirebaseFirestoreSwift

public class FirebaseUserSessionDataStore: UserSessionDataStore {
  
  private lazy var cloudDB = Firestore.firestore()
  
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
    let userID = userSession.profile.id
    
    var data = [FireStoreUtil.User.userID: userID,
                FireStoreUtil.User.name: userSession.profile.name,
                FireStoreUtil.User.email: userSession.profile.email]
    
    if let profileURL = userSession.profile.avatar {
      data[FireStoreUtil.User.profileURL] = profileURL
    }
    
    cloudDB.collection(FireStoreUtil.Collection.users).document(userID).setData(data) { err in
      if let err = err {
        print("Error writing document: \(err)")
      }
      else {
        print("Save user to firecloud store")
      }
    }
  }
  
  public func delete() {
    
  }
}
