//
//  KIIPUserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import GoogleSignIn

public class KIIPUserSessionRepository: UserSessionRepository {
  
  // MARK: - Properties
  let dataStore: UserSessionDataStore
  let remoteAPI: AuthRemoteAPI
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Methods
  public init(dataStore: UserSessionDataStore, remoteAPI: AuthRemoteAPI) {
    self.dataStore = dataStore
    self.remoteAPI = remoteAPI
  }
  
  public func readUserSession() -> UserSession? {
    return dataStore.readUserSession()
  }
  
  public func signUp(newAccount: NewAccount) -> Observable<UserSession> {
    let observable = remoteAPI.signUp(account: newAccount)
    
    observable
      .subscribe(onNext: { [weak self] userSession in
        self?.dataStore.save(userSession: userSession)
      })
      .disposed(by: disposeBag)
    
    return observable
  }
  
  public func signIn(email: String, password: String) -> Observable<UserSession> {
    let observable = remoteAPI.signIn(email: email, password: password)
    observable
      .subscribe(onNext: { [weak self] userSession in
        self?.dataStore.save(userSession: userSession)
      })
      .disposed(by: disposeBag)
    return observable
  }
  
  public func signIn(with credential: AuthCredential, provider: Provider) -> Observable<AuthState> {
    return Observable.error(AuthError.notSupported)
  }
  
  public func handleUserSelectFactorToLogIn(name: String) {}
  
  public func handleUserSelectedVerificationCode(_ code: String) {}
  
  public func signOut() {
    return dataStore.delete()
  }
}
