//
//  FirebaseUserSessionRepository.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import RxSwift
import GoogleSignIn
import Firebase
import RxCocoa
import FBSDKLoginKit

public class FirebaseUserSessionRepository: UserSessionRepository {
  
  let dataStore: UserSessionDataStore
  
  private var authState: BehaviorSubject<AuthState>?
  
  private var resolver: MultiFactorResolver?
  private var verificationID: String?
  
  private let disposeBag = DisposeBag()
  
  public init(dataStore: UserSessionDataStore) {
    self.dataStore = dataStore
  }
  
  private func listenForUserLoggedIn() {
    Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
      guard let strongSelf = self else { return }
      guard let user = user else {
        print("Not signed in")
        return
      }
      
      let userSession = strongSelf.makeUserSession(from: user)
      strongSelf.saveUserSession(userSession: userSession)
      strongSelf.authState?.onNext(.success(userSession: userSession))
      strongSelf.authState?.onCompleted()
    }
  }
  
  private func saveUserSession(userSession: UserSession) {
    dataStore.save(userSession: userSession)
  }
  
  private func makeUserSession(from user: User) -> UserSession {
    let profile = UserProfile(id: user.uid, name: user.displayName ?? "", email: user.email ?? "", avatar: user.photoURL?.absoluteString)
    let remoteSession = RemoteUserSession(token: user.refreshToken ?? "")
    let userSession = UserSession(profile: profile, remoteSession: remoteSession)
    return userSession
  }
  
  public func readUserSession() -> UserSession? {
    return dataStore.readUserSession()
  }
  
  public func signUp(newAccount: NewAccount) -> Observable<UserSession> {
    return Observable.error(AuthError.notSupported)
  }
  
  public func signIn(email: String, password: String) -> Observable<UserSession> {
    return Observable.error(AuthError.notSupported)
  }
  
  public func signIn(with credential: AuthCredential, provider: Provider) -> Observable<AuthState> {
    listenForUserLoggedIn()
    
    let isMFAEnabled = false
    
    authState = BehaviorSubject<AuthState>(value: .authenticating)
    
    Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
      if let error = error {
        let authError = error as NSError
        if (isMFAEnabled && authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
          // The user is a multi-factor user. Second factor challenge is required.
          let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
          var displayNameString = ""
          for tmpFactorInfo in (resolver.hints) {
            displayNameString += tmpFactorInfo.displayName ?? ""
            displayNameString += " "
          }
          self?.authState?.onNext(.waitingForDisplayName(displayName: displayNameString))
        } else {
          self?.authState?.onError(error)
          return
        }
        // ...
        return
      }
    }
    return authState!.asObservable()
  }
  
  public func handleUserSelectFactorToLogIn(name: String) {
    guard let state = try? authState?.value(),
      case AuthState.waitingForDisplayName = state else {
      return
    }
    guard let resolver = self.resolver else { return }
    
    var selectedHint: PhoneMultiFactorInfo?
    for tmpFactorInfo in resolver.hints {
      if (name == tmpFactorInfo.displayName) {
        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
      }
    }
    PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { [weak self] verificationID, error in
      if error != nil {
        print("Multi factor start sign in failed. Error: \(error.debugDescription)")
        self?.authState?.onError(error!)
      } else {
        self?.authState?.onNext(.waitingForVerificationCode(displayName: selectedHint?.displayName ?? ""))
      }
    }
  }
  
  public func handleUserSelectedVerificationCode(_ code: String) {
    guard let state = try? authState?.value(),
      case AuthState.waitingForVerificationCode = state else {
      return
    }
    
    guard let resolver = self.resolver,
      let verificationID = self.verificationID else { return }
    
    let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
    let assertion: MultiFactorAssertion = PhoneMultiFactorGenerator.assertion(with: credential)
    resolver.resolveSignIn(with: assertion) { [weak self] authResult, error in
      if error != nil {
        print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
        self?.authState?.onError(error!)
      } else {
        // Don't know what to do here while login success
      }
    }
  }
  
  public func signOut() {
    GIDSignIn.sharedInstance()?.signOut()
    LoginManager().logOut()
    try? Auth.auth().signOut()
  }
  
}
