//
//  KIIPUserSessionRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

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
  
  public func signIn(provider: Provider, token: String, clientId: String) -> Observable<UserSession> {
    let observable = remoteAPI.signIn(provider: provider, token: token, clientId: clientId)
    observable
      .subscribe(onNext: { [weak self] userSession in
        self?.dataStore.save(userSession: userSession)
      })
      .disposed(by: disposeBag)
    return observable
  }
  
  public func signOut(userSession: UserSession) {
    return dataStore.delete(userSession: userSession)
  }
}
